# Guía de PostgreSQL, SQLAlchemy y Alembic

Este documento explica los cambios realizados para preparar la versión 1.2 de EjerciciosApp. Está dirigido a alguien que comienza a trabajar con bases de datos y ORM.

## 1. Qué cambió

En la primera versión, el backend obtiene los ejercicios directamente de un archivo:

```text
FastAPI → exercise_repository.py → exercises.json
```

Estamos preparando una arquitectura nueva:

```text
FastAPI
   ↓
SQLAlchemy
   ↓
Psycopg
   ↓
PostgreSQL
```

Por ahora, el backend todavía consulta `exercises.json`. Lo que ya se construyó es la conexión, la descripción de la tabla y su migración. El siguiente paso será importar los registros y cambiar el repositorio.

## 2. Qué es PostgreSQL

PostgreSQL es el servidor que almacena los datos de manera permanente. A diferencia del archivo JSON, permite consultar, relacionar y modificar información de forma eficiente y segura.

Se creó una base llamada `EjerciciosApp`. Una base es el contenedor donde vivirán las tablas del proyecto:

```text
EjerciciosApp
├── exercises
├── users                 futura
├── favorite_exercises    futura
├── routines              futura
└── routine_exercises     futura
```

PostgreSQL funciona como un servicio en segundo plano. Por eso no abre una ventana propia. pgAdmin es solamente una interfaz visual para administrar ese servidor.

## 3. Qué es Psycopg

Psycopg es el controlador que permite que Python se comunique con PostgreSQL. Se encarga del protocolo de conexión, enviar SQL y recibir resultados.

Normalmente no se utilizará directamente porque SQLAlchemy trabajará encima de él:

```text
Nuestro código → SQLAlchemy → Psycopg → PostgreSQL
```

## 4. Qué es SQLAlchemy

SQLAlchemy permite representar tablas mediante clases de Python y construir consultas sin escribir todo el SQL manualmente. Es el ORM del proyecto.

Por ejemplo, conceptualmente:

```python
ExerciseModel.name
```

representa la columna:

```sql
exercises.name
```

SQLAlchemy no sustituye PostgreSQL. PostgreSQL guarda los datos; SQLAlchemy es la herramienta con la que el backend los consulta.

## 5. Variables de entorno

La conexión necesita host, puerto, nombre de base, usuario y contraseña. Esos datos se guardan en `backend/.env`:

```env
DB_HOST=localhost
DB_PORT=5432
DB_NAME=EjerciciosApp
DB_USER=postgres
DB_PASSWORD="contraseña local"
```

El archivo `.env` no debe subirse a GitHub. `.env.example` muestra qué variables se necesitan, pero no contiene la contraseña real.

Separar estos valores del código permite utilizar configuraciones distintas en desarrollo, pruebas y producción.

## 6. `app/config.py`

`config.py` carga las variables mediante `pydantic-settings` y construye una URL segura de SQLAlchemy:

```text
postgresql+psycopg://usuario:contraseña@host:puerto/base
```

Sus componentes significan:

- `postgresql`: tipo de base de datos.
- `psycopg`: controlador de Python.
- `usuario` y `contraseña`: credenciales.
- `host` y `puerto`: ubicación del servidor.
- `base`: base de datos seleccionada.

Se utiliza `URL.create()` para manejar correctamente contraseñas que contienen caracteres especiales.

## 7. `app/database.py`

Este archivo contiene cuatro elementos principales.

### `engine`

```python
engine = create_engine(settings.database_url, pool_pre_ping=True)
```

Es el punto central de conexión de SQLAlchemy. Administra un conjunto reutilizable de conexiones. `pool_pre_ping=True` comprueba que una conexión siga activa antes de reutilizarla.

### `SessionLocal`

Una sesión representa una unidad de trabajo con la base. Se utilizará para consultar, insertar, modificar y confirmar datos.

```python
with SessionLocal() as session:
    ...
```

### `Base`

Todos los modelos de tablas heredan de `Base`. Así SQLAlchemy reúne sus metadatos: nombres de tablas, columnas, tipos, claves e índices.

### `get_db`

Es una dependencia preparada para FastAPI. Entregará una sesión a un endpoint y la cerrará cuando termine la petición, incluso si ocurre un error.

## 8. Modelos Pydantic y SQLAlchemy

El proyecto tiene dos clases relacionadas con ejercicios, pero no son duplicadas accidentalmente:

```text
app/models/exercise.py
└── Pydantic: valida el JSON enviado por la API

app/db_models/exercise.py
└── SQLAlchemy: representa la tabla de PostgreSQL
```

Pydantic controla el contrato externo. SQLAlchemy controla el almacenamiento interno. Esta separación permite cambiar la base sin alterar necesariamente la respuesta que consume Flutter.

## 9. `ExerciseModel`

La clase declara la tabla `exercises`:

```python
class ExerciseModel(Base):
    __tablename__ = "exercises"
```

Columnas principales:

| Columna | Tipo | Uso |
|---|---|---|
| `id` | `String(20)` | Identificador único y clave primaria |
| `name` | `String(255)` | Nombre del ejercicio |
| `category` | `String(100)` | Categoría del dataset |
| `body_part` | `String(100)` | Parte general del cuerpo |
| `equipment` | `String(100)` | Equipo requerido |
| `instructions` | `JSONB` | Instrucciones completas por idioma |
| `instruction_steps` | `JSONB` | Pasos separados por idioma |
| `muscle_group` | `String(100)` | Grupo muscular |
| `secondary_muscles` | `JSONB` | Lista de músculos secundarios |
| `target` | `String(100)` | Músculo principal |
| `media_id` | `String(100)` | Identificador multimedia |
| `image` | `Text` | Ruta de la imagen |
| `gif_url` | `Text` | Ruta del GIF |
| `attribution` | `Text` | Crédito del recurso |
| `created_at` | `DateTime` | Fecha del registro |

`id` es la clave primaria: no puede repetirse. Las columnas usadas frecuentemente para filtros tienen índices, lo que ayuda a PostgreSQL a localizarlas sin recorrer siempre toda la tabla.

### Por qué se usa `JSONB`

Algunos campos tienen estructuras anidadas:

```json
{
  "es": ["Paso uno", "Paso dos"],
  "en": ["Step one", "Step two"]
}
```

`JSONB` conserva listas y objetos como datos JSON consultables. Es apropiado para las traducciones y los músculos secundarios en esta etapa.

## 10. Qué es Alembic

Alembic controla los cambios de estructura de la base. Una migración es un archivo versionado que describe cómo avanzar o retroceder el esquema.

Esto evita crear tablas manualmente en cada computadora.

```text
Modelo SQLAlchemy
       ↓ autogenerate
Archivo de migración
       ↓ upgrade
Tabla PostgreSQL
```

## 11. `migrations/env.py`

Este archivo conecta Alembic con el proyecto:

- Importa la configuración y el motor.
- Importa `ExerciseModel` para registrarlo.
- Entrega `Base.metadata` a Alembic.
- Abre una conexión cuando se aplica una migración.

Sin importar el modelo, Alembic no sabría que debe crear `exercises`.

## 12. Primera migración

La migración `617e6fa2a5fe_create_exercises_table.py` contiene dos funciones.

### `upgrade()`

Crea la tabla, sus columnas, clave primaria e índices. Se ejecutó mediante:

```powershell
alembic upgrade head
```

### `downgrade()`

Describe cómo deshacer esa migración eliminando índices y tabla. No debe ejecutarse accidentalmente porque eliminaría la tabla y sus datos.

## 13. Tabla `alembic_version`

Alembic crea automáticamente `alembic_version`. Guarda el identificador de la última migración aplicada:

```text
617e6fa2a5fe
```

No contiene ejercicios ni se edita manualmente. Sirve para que Alembic sepa si la base está actualizada.

## 14. Comandos importantes

Crear una nueva migración después de modificar modelos:

```powershell
alembic revision --autogenerate -m "descripcion del cambio"
```

Aplicar migraciones pendientes:

```powershell
alembic upgrade head
```

Ver la migración actual:

```powershell
alembic current
```

Ver el historial:

```powershell
alembic history
```

Las migraciones generadas deben revisarse antes de aplicarse. `--autogenerate` ayuda, pero no comprende por sí solo todas las intenciones del desarrollador.

## 15. Estado actual

Ya está completado:

- PostgreSQL instalado y en ejecución.
- Base `EjerciciosApp` creada.
- Conexión desde Python comprobada.
- Psycopg, SQLAlchemy y Alembic instalados.
- Configuración mediante `.env`.
- Modelo `ExerciseModel` definido.
- Primera migración generada y aplicada.
- Tablas `exercises` y `alembic_version` creadas.

Todavía falta:

1. Importar los 1,324 ejercicios desde JSON.
2. Verificar que todos se insertaron correctamente.
3. Cambiar `exercise_repository.py` para consultar PostgreSQL.
4. Adaptar servicios y rutas para recibir sesiones.
5. Mantener las respuestas actuales para no romper Flutter.
6. Preparar una base separada o sustituciones para las pruebas.

## 16. Próximo flujo

Cuando termine la importación, una petición funcionará así:

```text
Flutter
   ↓ GET /api/v1/exercises?muscle=pectorals
FastAPI Route
   ↓
Exercise Service
   ↓
Exercise Repository
   ↓ consulta SQLAlchemy
PostgreSQL
   ↑ filas
Repository → Service → Pydantic → JSON → Flutter
```

La aplicación móvil no necesita conocer PostgreSQL ni SQLAlchemy. Solo conoce la API HTTP, por lo que puede seguir funcionando si conservamos el mismo contrato JSON.
