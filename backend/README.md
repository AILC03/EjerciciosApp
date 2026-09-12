# Backend de EjerciciosApp

API REST de EjerciciosApp desarrollada con FastAPI. Administra el catálogo de ejercicios, los usuarios y sus favoritos mediante PostgreSQL.

En la V1.3 el catálogo sigue siendo público. La autenticación solamente es necesaria para guardar y consultar favoritos. La generación de rutinas con IA todavía no forma parte del backend.

## Responsabilidades

- Entregar músculos, equipos y partes del cuerpo disponibles.
- Consultar, filtrar, buscar y paginar ejercicios.
- Entregar el detalle completo de un ejercicio.
- Registrar usuarios con correos únicos.
- Verificar contraseñas sin almacenarlas en texto plano.
- Crear y validar tokens JWT.
- Identificar al usuario de una petición protegida.
- Guardar, listar y eliminar sus ejercicios favoritos.
- Validar entradas y respuestas con Pydantic.
- Gestionar PostgreSQL mediante SQLAlchemy y Alembic.

## Tecnologías

| Tecnología | Responsabilidad |
|---|---|
| Python | Lenguaje del backend |
| FastAPI | Endpoints, dependencias y OpenAPI |
| Uvicorn | Servidor ASGI |
| Pydantic | Validación de entradas y respuestas |
| PostgreSQL | Persistencia |
| SQLAlchemy | Modelos y consultas ORM |
| Psycopg | Comunicación con PostgreSQL |
| Alembic | Migraciones del esquema |
| `pwdlib` | Hash y verificación de contraseñas |
| PyJWT | Creación y validación de tokens |
| Pytest | Pruebas automatizadas |

## Arquitectura

```text
Petición HTTP
     │
     ▼
Routes
     │ valida parámetros y códigos HTTP
     ▼
Services
     │ aplica reglas de negocio
     ▼
Repositories
     │ ejecuta consultas SQLAlchemy
     ▼
PostgreSQL
```

Las peticiones protegidas pasan además por `security/dependencies.py`, que extrae el token Bearer, lo valida y obtiene el usuario actual.

## Estructura principal

```text
backend/
├── app/
│   ├── main.py
│   ├── config.py
│   ├── database.py
│   ├── db_models/
│   │   ├── exercise.py
│   │   ├── user.py
│   │   └── favorite.py
│   ├── models/
│   │   ├── exercise.py
│   │   ├── user.py
│   │   └── favorite.py
│   ├── repositories/
│   │   ├── exercise_repository.py
│   │   ├── user_repository.py
│   │   └── favorite_repository.py
│   ├── services/
│   │   ├── exercise_service.py
│   │   ├── user_service.py
│   │   └── favorite_service.py
│   ├── security/
│   │   ├── passwords.py
│   │   ├── tokens.py
│   │   └── dependencies.py
│   └── routes/
│       ├── exercises.py
│       ├── auth.py
│       └── favorites.py
├── migrations/versions/
├── scripts/seed_exercises.py
├── data/exercises.json
├── test/
├── alembic.ini
├── .env.example
└── requirements.txt
```

## Función de las carpetas

### `db_models`

Describe las tablas reales de PostgreSQL con SQLAlchemy:

- `ExerciseModel`: catálogo de ejercicios.
- `UserModel`: usuarios, correo, hash, estado y fechas.
- `FavoriteModel`: relación entre usuarios y ejercicios.

### `models`

Contiene esquemas Pydantic. Estos modelos representan los datos que la API acepta o devuelve; no ejecutan consultas.

### `repositories`

Es la capa de acceso a datos. Centraliza consultas, inserciones y eliminaciones para evitar SQL dentro de rutas o servicios.

### `services`

Contiene reglas de negocio: normalización de filtros, paginación, validación de credenciales, prevención de duplicados y serialización de ejercicios.

### `security`

- `passwords.py`: crea y comprueba hashes de contraseña.
- `tokens.py`: crea JWT con fecha de expiración y los decodifica.
- `dependencies.py`: implementa `get_current_user` para proteger endpoints.

### `routes`

Expone las operaciones HTTP. Convierte excepciones del servicio en respuestas como `401`, `404` o `409`.

## Base de datos

### Tabla `exercises`

Contiene los datos importados desde el JSON: nombre, músculo objetivo, equipo, instrucciones, imagen, GIF y atribución.

### Tabla `users`

Campos principales:

- `id`: UUID del usuario.
- `email`: correo único.
- `password_hash`: contraseña transformada mediante hash.
- `is_active`: permite desactivar la cuenta.
- `created_at`: fecha de registro.

### Tabla `favorites`

Relaciona `user_id` con `exercise_id`. Ambos campos forman su clave primaria, por lo que un usuario no puede guardar dos veces el mismo ejercicio. Las claves foráneas mantienen la integridad de la relación.

## Endpoints

### Públicos

| Método | Ruta | Resultado |
|---|---|---|
| GET | `/health` | Estado del servidor |
| GET | `/api/v1/muscles` | Músculos disponibles |
| GET | `/api/v1/equipment` | Equipos disponibles |
| GET | `/api/v1/body-parts` | Partes del cuerpo |
| GET | `/api/v1/exercises` | Catálogo filtrado y paginado |
| GET | `/api/v1/exercises/{exercise_id}` | Detalle del ejercicio |
| POST | `/api/v1/auth/register` | Registro |
| POST | `/api/v1/auth/login` | Inicio de sesión |

`GET /api/v1/exercises` admite:

| Parámetro | Descripción |
|---|---|
| `muscle` | Músculo objetivo |
| `search` | Texto en el nombre |
| `equipment` | Equipo |
| `body_part` | Parte del cuerpo |
| `page` | Página desde 1 |
| `page_size` | Entre 1 y 100 |

Ejemplo:

```http
GET /api/v1/exercises?muscle=pectorals&page=1&page_size=20
```

### Protegidos

| Método | Ruta | Resultado |
|---|---|---|
| GET | `/api/v1/auth/me` | Usuario actual |
| GET | `/api/v1/favorites` | Ejercicios favoritos |
| POST | `/api/v1/favorites/{exercise_id}` | Agrega un favorito |
| DELETE | `/api/v1/favorites/{exercise_id}` | Elimina un favorito |

Requieren:

```http
Authorization: Bearer TOKEN_JWT
```

## Flujo de autenticación

```text
Registro
  → Pydantic valida correo y contraseña
  → se comprueba que el correo no exista
  → pwdlib genera el hash
  → SQLAlchemy guarda el usuario

Login
  → se busca el usuario por correo
  → pwdlib verifica la contraseña
  → PyJWT crea un token con el UUID y expiración

Petición protegida
  → se extrae el Bearer token
  → se valida firma y expiración
  → se carga el usuario
  → se ejecuta la operación solicitada
```

La contraseña debe tener entre 8 y 128 caracteres. El token dura 30 minutos de forma predeterminada.

## Respuestas importantes

- `201 Created`: usuario o favorito creado.
- `204 No Content`: favorito eliminado.
- `401 Unauthorized`: credenciales o token inválidos.
- `403 Forbidden`: usuario inactivo.
- `404 Not Found`: ejercicio o favorito inexistente.
- `409 Conflict`: correo o favorito duplicado.
- `422 Unprocessable Entity`: entrada inválida.

## Configuración

Copia la plantilla:

```powershell
Copy-Item .env.example .env
```

Variables:

```dotenv
DB_HOST=localhost
DB_PORT=5432
DB_NAME=EjerciciosApp
DB_USER=postgres
DB_PASSWORD=tu_contrasena_local
JWT_SECRET_KEY=genera_una_clave_secreta
JWT_ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
```

`.env` contiene secretos locales y no debe subirse al repositorio.

## Migraciones y catálogo

Crear o actualizar las tablas:

```powershell
alembic upgrade head
```

Importar `data/exercises.json`:

```powershell
python -m scripts.seed_exercises
```

El seed conserva los IDs del dataset y omite registros ya existentes.

## Ejecución

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install -r requirements.txt
Copy-Item .env.example .env
alembic upgrade head
python -m scripts.seed_exercises
python -m uvicorn app.main:app --reload
```

- API: `http://127.0.0.1:8000`
- Swagger: `http://127.0.0.1:8000/docs`
- Health: `http://127.0.0.1:8000/health`

## CORS

El backend admite durante el desarrollo los orígenes web configurados en `app/config.py`. Actualmente están previstos `localhost:5173` y `127.0.0.1:5173`, con métodos `GET`, `POST` y `DELETE`.

CORS controla qué páginas web pueden leer la API desde el navegador; no reemplaza la autenticación JWT.

## Pruebas

```powershell
python -m pytest -v
```

Las pruebas cubren catálogo, filtros, contraseñas, registro, login, tokens, usuario actual, autorización y operaciones de favoritos.

## Fuente de datos

El catálogo procede de [`hasaneyldrm/exercises-dataset`](https://github.com/hasaneyldrm/exercises-dataset). Las peticiones normales consultan PostgreSQL; el JSON solamente se usa para la carga inicial.

## Pendiente

- Renovación de tokens.
- Recuperación de contraseña y verificación de correo.
- Despliegue con HTTPS y configuración de producción.
- Perfiles e historial de entrenamiento.
- Generación futura de rutinas con IA.
