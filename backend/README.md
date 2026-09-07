# ¿Qué hace el backend de EjerciciosApp?

## 1. Propósito

El backend de **EjerciciosApp** es una API REST creada con Python y FastAPI. Su propósito en la primera versión es entregar al frontend un catálogo de ejercicios que puede consultarse, buscarse y filtrarse.

La aplicación todavía no genera rutinas con inteligencia artificial. La opción futura **“Haz mi rutina”** queda fuera del alcance de esta versión.

Actualmente el backend puede:

- Comprobar que el servidor está funcionando.
- Consultar un catálogo de 1,324 ejercicios almacenado en PostgreSQL.
- Devolver los ejercicios por páginas.
- Buscar ejercicios por nombre.
- Filtrar por músculo principal, equipo y parte del cuerpo.
- Consultar un ejercicio específico mediante su ID.
- Entregar las opciones disponibles de músculos, equipos y partes del cuerpo.
- Validar la estructura de las respuestas con Pydantic.
- Proporcionar URLs públicas para las imágenes y GIF de los ejercicios.
- Autorizar peticiones del frontend local mediante CORS.
- Ejecutar pruebas automatizadas de sus funciones principales.

## 2. Tecnologías utilizadas

- **Python:** lenguaje principal.
- **FastAPI:** creación de endpoints y documentación de la API.
- **CORSMiddleware:** autorización de peticiones web provenientes del frontend.
- **Uvicorn:** servidor que ejecuta la aplicación FastAPI.
- **Pydantic:** definición y validación de los modelos de respuesta.
- **Pytest:** ejecución de pruebas automatizadas.
- **HTTPX/TestClient:** simulación de peticiones HTTP durante las pruebas.
- **PostgreSQL:** almacenamiento persistente del catálogo.
- **SQLAlchemy:** ORM utilizado para modelar y consultar las tablas.
- **Psycopg:** controlador que comunica SQLAlchemy con PostgreSQL.
- **Alembic:** creación y versionado del esquema de la base de datos.
- **JSON:** fuente del catálogo utilizada durante la carga inicial.

## 3. Estructura del proyecto

```text
backend/
├── app/
│   ├── __init__.py
│   ├── main.py
│   ├── config.py
│   ├── models/
│   │   ├── __init__.py
│   │   └── exercise.py
│   ├── repositories/
│   │   ├── __init__.py
│   │   └── exercise_repository.py
│   ├── services/
│   │   ├── __init__.py
│   │   └── exercise_service.py
│   └── routes/
│       ├── __init__.py
│       └── exercises.py
├── data/
│   └── exercises.json
├── test/
│   ├── __init__.py
│   └── test_exercises.py
├── pytest.ini
└── requirements.txt
```

## 4. Responsabilidad de cada archivo

### `app/main.py`

Es el punto de entrada del backend. Crea la aplicación FastAPI, configura el middleware de CORS, registra el router de ejercicios y define el endpoint `/health`.

Uvicorn busca la variable `app` de este archivo cuando se ejecuta:

```powershell
python -m uvicorn app.main:app --reload
```

La configuración de CORS permite solicitudes `GET` desde los orígenes autorizados y deja que el navegador utilice los encabezados necesarios. Como la V1 no tiene usuarios ni sesiones, las credenciales permanecen desactivadas.

`main.py` no contiene las reglas para buscar o filtrar ejercicios. Su responsabilidad es iniciar y configurar la aplicación.

### `app/config.py`

Centraliza valores de configuración. Actualmente contiene la dirección base del repositorio multimedia:

```text
https://raw.githubusercontent.com/hasaneyldrm/exercises-dataset/main
```

Esta dirección permite convertir una ruta como:

```text
images/0001-2gPfomN.jpg
```

en una URL que el frontend puede abrir.

También declara los orígenes web que pueden comunicarse con el backend durante el desarrollo:

```text
http://localhost:5173
http://127.0.0.1:5173
```

Aunque ambas direcciones apuntan a la computadora local, el navegador las considera orígenes diferentes. Si el frontend se ejecuta en otro dominio o puerto, será necesario agregar su origen a esta configuración.

### `app/models/exercise.py`

Contiene los modelos Pydantic que describen las respuestas de la API.

- `Exercise`: representa el detalle completo, incluyendo instrucciones, músculos secundarios y datos multimedia.
- `ExerciseSummary`: representa un ejercicio resumido para las tarjetas del catálogo.
- `ExerciseListResponse`: representa una página del catálogo junto con sus filtros y metadatos.
- `OptionListResponse`: representa una lista de opciones como músculos, equipos o partes del cuerpo.

Los modelos permiten que FastAPI valide los datos y muestre sus estructuras en `/docs`.

### `app/repositories/exercise_repository.py`

Es la capa de acceso a PostgreSQL. Construye consultas SQLAlchemy para obtener ejercicios paginados, buscar por ID y recuperar valores únicos de músculos, equipos y partes del cuerpo.

`app/database.py` crea el motor y las sesiones. `app/db_models/exercise.py` relaciona `ExerciseModel` con la tabla `exercises`.

### `app/services/exercise_service.py`

Es la capa que contiene la lógica de la aplicación. Recibe los datos del repositorio y realiza operaciones como:

- Normalizar textos para ignorar mayúsculas, minúsculas y espacios exteriores.
- Filtrar por el campo `target` cuando se solicita un músculo.
- Buscar una palabra dentro del nombre del ejercicio.
- Filtrar por `equipment`.
- Filtrar por `body_part`.
- Aplicar la paginación después de los filtros.
- Obtener valores únicos para los selectores del frontend.
- Convertir las rutas de imágenes y GIF en URLs públicas.

El servicio no define URLs ni códigos HTTP. Solo contiene reglas de la aplicación.

### `app/routes/exercises.py`

Define los endpoints HTTP. Recibe los parámetros enviados por el frontend, llama al servicio y construye la respuesta.

Esta capa también establece:

- Valores predeterminados.
- Límites permitidos para la paginación.
- Modelos de respuesta.
- Errores como `404 Not Found`.

### `data/exercises.json`

Es la fuente de importación inicial. Procede del repositorio [`hasaneyldrm/exercises-dataset`](https://github.com/hasaneyldrm/exercises-dataset) y contiene 1,324 ejercicios.

Cada registro puede incluir nombre, parte del cuerpo, músculo objetivo, equipo, instrucciones en varios idiomas, imagen, GIF y atribución.

El script `scripts/seed_exercises.py` sincroniza estos datos con PostgreSQL sin duplicar IDs. Los endpoints no leen el JSON durante las peticiones.

### `test/test_exercises.py`

Contiene pruebas automatizadas. `TestClient` simula peticiones sin tener que iniciar Uvicorn manualmente.

Las pruebas comprueban el estado del servidor, filtros, paginación, búsqueda por ID, errores, listas de opciones y encabezados CORS.

### `pytest.ini`

Configura Pytest para reconocer la carpeta del proyecto y localizar las pruebas.

### `requirements.txt`

Registra las dependencias y versiones instaladas para que el proyecto pueda reproducirse en otra computadora.

## 5. Flujo de una petición

Supongamos que el frontend envía:

```http
GET /api/v1/exercises?muscle=biceps&page=1&page_size=5
```

El flujo es el siguiente:

1. Uvicorn recibe la petición HTTP.
2. FastAPI encuentra la ruta correspondiente en `routes/exercises.py`.
3. FastAPI valida que `page` y `page_size` sean valores permitidos.
4. La ruta entrega los parámetros a `exercise_service.py`.
5. El servicio solicita los ejercicios a `exercise_repository.py`.
6. El repositorio devuelve la lista que ya está cargada en memoria.
7. El servicio conserva los registros cuyo `target` sea `biceps`.
8. El servicio calcula el total de coincidencias.
9. El servicio selecciona los cinco ejercicios de la primera página.
10. El servicio transforma las rutas multimedia en URLs públicas.
11. La ruta crea la respuesta con resultados y metadatos.
12. Pydantic valida y limita cada elemento al modelo `ExerciseSummary`.
13. FastAPI convierte el resultado a JSON.
14. Uvicorn envía la respuesta al frontend.

Representación resumida:

```text
Frontend
   ↓ petición HTTP
Routes
   ↓ parámetros
Services
   ↓ consulta
Repository
   ↓
exercises.json
   ↑ datos
Repository → Services → Routes → Pydantic → respuesta JSON
```

## 6. Endpoints disponibles

### Estado del servidor

```http
GET /health
```

Respuesta:

```json
{
  "status": "ok"
}
```

### Catálogo de ejercicios

```http
GET /api/v1/exercises
```

Parámetros opcionales:

| Parámetro | Función | Ejemplo |
|---|---|---|
| `muscle` | Filtra por músculo objetivo (`target`) | `biceps` |
| `search` | Busca texto dentro del nombre | `press` |
| `equipment` | Filtra por equipo | `dumbbell` |
| `body_part` | Filtra por región corporal | `chest` |
| `page` | Selecciona la página; mínimo 1 | `1` |
| `page_size` | Elementos por página; entre 1 y 100 | `20` |

Los filtros pueden combinarse:

```http
GET /api/v1/exercises?body_part=chest&equipment=dumbbell&page=1&page_size=5
```

Ejemplo de respuesta resumida:

```json
{
  "total": 45,
  "page": 1,
  "page_size": 5,
  "pages": 9,
  "muscle": null,
  "search": null,
  "equipment": "dumbbell",
  "body_part": "chest",
  "items": [
    {
      "id": "0001",
      "name": "Ejercicio de ejemplo",
      "body_part": "chest",
      "target": "pectorals",
      "muscle_group": "pectorals",
      "equipment": "dumbbell",
      "image": "https://...",
      "gif_url": "https://..."
    }
  ]
}
```

`total` representa todas las coincidencias; no solamente los elementos incluidos en la página actual.

### Detalle de un ejercicio

```http
GET /api/v1/exercises/{exercise_id}
```

Ejemplo:

```http
GET /api/v1/exercises/0001
```

Devuelve el ejercicio completo. Si el ID no existe, responde con código `404`:

```json
{
  "detail": "Ejercicio no encontrado"
}
```

### Músculos disponibles

```http
GET /api/v1/muscles
```

Devuelve los valores únicos de `target`.

### Equipos disponibles

```http
GET /api/v1/equipment
```

Devuelve los valores únicos de `equipment`.

### Partes del cuerpo disponibles

```http
GET /api/v1/body-parts
```

Devuelve los valores únicos de `body_part`.

## 7. Paginación

La paginación se aplica después de todos los filtros. Para calcular qué registros corresponden a una página se utiliza:

```python
start = (page - 1) * page_size
end = start + page_size
```

La cantidad de páginas se calcula redondeando hacia arriba:

```python
pages = (total + page_size - 1) // page_size
```

Por ejemplo, 1,324 ejercicios con 20 elementos por página producen 67 páginas.

## 8. Resumen y detalle

El catálogo utiliza `ExerciseSummary` para no enviar las instrucciones en todos los idiomas dentro de cada tarjeta. Esto reduce el tamaño de las respuestas.

```text
GET /exercises       → datos resumidos
GET /exercises/0001  → datos completos
```

## 9. Manejo de errores

- Un ejercicio inexistente produce `404 Not Found`.
- Una página menor que 1 produce `422 Unprocessable Entity`.
- Un `page_size` menor que 1 o mayor que 100 produce `422 Unprocessable Entity`.
- Los modelos Pydantic detectan respuestas con campos faltantes o tipos incompatibles.

## 10. Configuración de CORS

CORS significa *Cross-Origin Resource Sharing*. Es el mecanismo mediante el cual el backend indica al navegador qué aplicaciones web pueden leer sus respuestas.

Durante el desarrollo, el frontend puede ejecutarse en:

```text
http://localhost:5173
```

mientras el backend se ejecuta en:

```text
http://127.0.0.1:8000
```

Como el puerto y la dirección son diferentes, pertenecen a orígenes distintos. El middleware configurado en `main.py` añade encabezados como:

```http
Access-Control-Allow-Origin: http://localhost:5173
```

La configuración actual permite:

- Los orígenes `http://localhost:5173` y `http://127.0.0.1:5173`.
- Peticiones con método `GET`.
- Los encabezados que necesite enviar el frontend.
- Peticiones sin cookies ni credenciales de sesión.

El flujo es:

```text
Frontend en el puerto 5173
            ↓ petición
Middleware de CORS comprueba el origen
            ↓ origen autorizado
FastAPI ejecuta el endpoint
            ↓
El navegador permite leer la respuesta
```

CORS no sustituye la autenticación ni impide que otros programas consulten una API pública. Es una política aplicada principalmente por los navegadores. Cuando se incorporen operaciones `POST` o autenticación, la configuración deberá revisarse.

Las pruebas automatizadas comprueban que el origen del frontend recibe `Access-Control-Allow-Origin` y que un origen desconocido no recibe ese encabezado.

## 11. Limitaciones actuales

- PostgreSQL debe estar disponible para atender las consultas.
- El catálogo es de solo lectura.
- No existen usuarios, autenticación ni progreso personal.
- Los recursos multimedia dependen de GitHub.
- CORS solo contempla los orígenes locales del frontend; un despliegue requerirá agregar el dominio real.
- No se ha implementado la generación de rutinas con IA.

## 12. Próximos pasos

1. Añadir pruebas de búsqueda y combinaciones de filtros.
2. Mover configuraciones variables a un archivo `.env`.
3. Mejorar el manejo de errores al cargar el dataset.
4. Conectar el frontend con el catálogo y los selectores.
5. Evaluar almacenamiento local o externo para los recursos multimedia.
6. Agregar usuarios, autenticación y ejercicios favoritos.
7. Diseñar en una versión futura la funcionalidad **“Haz mi rutina”**.

## 13. Ejecución del proyecto

Con PostgreSQL activo y el entorno virtual preparado:

```powershell
Copy-Item .env.example .env
alembic upgrade head
python -m scripts.seed_exercises
python -m uvicorn app.main:app --reload
```

Direcciones principales:

- API: `http://127.0.0.1:8000`
- Documentación interactiva: `http://127.0.0.1:8000/docs`
- Estado: `http://127.0.0.1:8000/health`

Para ejecutar las pruebas:

```powershell
python -m pytest -v
```

En conclusión, el backend funciona como una capa organizada entre Flutter y PostgreSQL: recibe consultas, aplica reglas, accede a los datos mediante SQLAlchemy, valida resultados y entrega respuestas JSON listas para mostrarse.
