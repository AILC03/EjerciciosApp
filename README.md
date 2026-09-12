# EjerciciosApp

Aplicación universitaria para explorar ejercicios por músculo principal. Incluye una aplicación multiplataforma desarrollada con Flutter y una API REST construida con FastAPI y PostgreSQL.

La versión 1.3 permite utilizar el catálogo sin una cuenta. El registro y el inicio de sesión son opcionales y habilitan una colección personal de ejercicios favoritos.

La generación de rutinas con inteligencia artificial, identificada como **«Haz mi rutina»**, está planeada para una versión futura y todavía no está implementada.

## Funcionalidades de la V1.3

- Selección visual de grupos musculares.
- Catálogo filtrado por músculo principal.
- Tarjetas con imagen, nombre, equipo y botón de favorito.
- Detalle con GIF, equipo, músculos, instrucciones y control de favorito.
- Interfaz en español e inglés con preferencia persistente.
- Tema oscuro, skeletons y caché de imágenes.
- Registro e inicio de sesión opcionales.
- Sesiones mediante tokens JWT.
- Almacenamiento seguro del token en el dispositivo.
- Favoritos independientes para cada usuario.
- Favoritos agrupados en menús desplegables por músculo.
- API documentada mediante OpenAPI y Swagger.
- Pruebas automatizadas del backend y la aplicación Flutter.

## Arquitectura general

```text
Flutter
  ├── Pantallas y widgets
  ├── Controllers (estado)
  ├── Services (peticiones HTTP)
  └── TokenStorage (sesión local)
             │ HTTP/JSON + Bearer JWT
             ▼
FastAPI
  ├── Routes (endpoints)
  ├── Security (contraseñas y JWT)
  ├── Services (reglas de negocio)
  └── Repositories (consultas SQLAlchemy)
             │
             ▼
PostgreSQL
  ├── exercises
  ├── users
  └── favorites
```

El repositorio contiene ambos proyectos:

```text
EjerciciosApp/
├── backend/     API REST, migraciones, seed y pruebas
├── mobile/      Aplicación Flutter para Android y web
├── .gitignore
└── README.md
```

Consulta la documentación específica en [backend/README.md](backend/README.md) y [mobile/README.md](mobile/README.md).

## Tecnologías

| Componente | Tecnología | Uso |
|---|---|---|
| Cliente | Flutter y Dart | Interfaz y navegación |
| Estado | Provider | Autenticación y favoritos compartidos |
| HTTP | `http` | Comunicación con FastAPI |
| Sesión local | `flutter_secure_storage` | Conservación segura del JWT |
| Imágenes | `cached_network_image` | Descarga y caché multimedia |
| Backend | Python, FastAPI y Uvicorn | API REST |
| Validación | Pydantic | Datos de entrada y salida |
| Autenticación | PyJWT y `pwdlib` | Tokens y hash de contraseñas |
| Base de datos | PostgreSQL | Ejercicios, usuarios y favoritos |
| Persistencia | SQLAlchemy y Psycopg | ORM y conexión a PostgreSQL |
| Migraciones | Alembic | Versionado del esquema |
| Pruebas | Pytest y Flutter Test | Verificación automática |

## Requisitos

- Git.
- Python 3.12 o compatible.
- PostgreSQL en ejecución.
- Flutter SDK.
- Android Studio, Android SDK y un emulador o dispositivo Android.

Para compilar o ejecutar iOS se requiere macOS con Xcode.

## Instalación

### 1. Clonar el repositorio

```powershell
git clone https://github.com/AILC03/EjerciciosApp.git
cd EjerciciosApp
```

### 2. Preparar el backend

```powershell
cd backend
python -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install -r requirements.txt
Copy-Item .env.example .env
```

Edita `.env` y configura la contraseña de PostgreSQL y una clave JWT privada. Después crea las tablas y carga el catálogo:

```powershell
alembic upgrade head
python -m scripts.seed_exercises
python -m uvicorn app.main:app --reload
```

Direcciones locales:

- API: `http://127.0.0.1:8000`
- Estado: `http://127.0.0.1:8000/health`
- Swagger: `http://127.0.0.1:8000/docs`

### 3. Ejecutar Flutter en Android

En otra terminal:

```powershell
cd mobile
flutter pub get
flutter devices
flutter run -d emulator-5554
```

El emulador Android utiliza de forma predeterminada `http://10.0.2.2:8000` para comunicarse con el backend de Windows.

### 4. Ejecutar Flutter en Chrome

```powershell
cd mobile
flutter run -d chrome --web-port 5173 --dart-define=API_BASE_URL=http://127.0.0.1:8000
```

El puerto `5173` coincide con los orígenes CORS permitidos durante el desarrollo.

## Configuración

El backend lee desde `backend/.env`:

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

No se debe subir `.env` a GitHub. `.env.example` sirve como plantilla sin secretos reales.

Flutter obtiene la dirección de la API mediante `API_BASE_URL`:

```powershell
flutter run --dart-define=API_BASE_URL=http://DIRECCION:8000
```

Si no se proporciona, utiliza `http://10.0.2.2:8000`, apropiado para el emulador Android.

## Endpoints principales

### Catálogo público

| Método | Ruta | Descripción |
|---|---|---|
| GET | `/health` | Comprueba el servidor |
| GET | `/api/v1/muscles` | Lista músculos disponibles |
| GET | `/api/v1/exercises` | Lista, filtra y pagina ejercicios |
| GET | `/api/v1/exercises/{id}` | Obtiene el detalle |
| GET | `/api/v1/equipment` | Lista equipos |
| GET | `/api/v1/body-parts` | Lista partes del cuerpo |

### Autenticación

| Método | Ruta | Descripción |
|---|---|---|
| POST | `/api/v1/auth/register` | Crea un usuario |
| POST | `/api/v1/auth/login` | Devuelve un token JWT |
| GET | `/api/v1/auth/me` | Devuelve el usuario autenticado |

### Favoritos protegidos

| Método | Ruta | Descripción |
|---|---|---|
| GET | `/api/v1/favorites` | Lista los favoritos del usuario |
| POST | `/api/v1/favorites/{exercise_id}` | Guarda un ejercicio |
| DELETE | `/api/v1/favorites/{exercise_id}` | Elimina un ejercicio |

Las rutas protegidas esperan el encabezado:

```http
Authorization: Bearer TOKEN_JWT
```

## Flujo principal

1. La aplicación puede abrirse y consultar el catálogo sin iniciar sesión.
2. Flutter solicita los músculos y muestra la selección inicial.
3. Al elegir un músculo, solicita los ejercicios filtrados.
4. El detalle se solicita mediante el ID del ejercicio.
5. Al intentar guardar un favorito sin sesión, se abre el flujo de autenticación.
6. El backend valida las credenciales y entrega un JWT.
7. Flutter guarda el token con `flutter_secure_storage`.
8. Las peticiones de favoritos envían el token en el encabezado `Authorization`.
9. PostgreSQL relaciona el usuario y el ejercicio en la tabla `favorites`.

Las contraseñas nunca se almacenan en texto plano: el backend conserva únicamente su hash.

## Base de datos

Alembic administra las tablas:

- `exercises`: catálogo importado desde JSON.
- `users`: correo, hash de contraseña, estado y fecha de creación.
- `favorites`: relación entre un usuario y un ejercicio.

La clave compuesta de `favorites` evita que un usuario guarde dos veces el mismo ejercicio.

## Pruebas y calidad

Backend:

```powershell
cd backend
python -m pytest -v
```

Flutter:

```powershell
cd mobile
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

## Fuente de datos

El catálogo inicial procede de [`hasaneyldrm/exercises-dataset`](https://github.com/hasaneyldrm/exercises-dataset). El script `backend/scripts/seed_exercises.py` importa los registros a PostgreSQL sin duplicar sus IDs.

Los nombres de ejercicios permanecen en inglés cuando el dataset no proporciona una traducción revisada. Los músculos, equipos, mensajes e instrucciones disponibles sí se adaptan al idioma activo.

## Limitaciones actuales

- El catálogo muestra hasta 20 ejercicios por músculo en Flutter.
- Los recursos multimedia dependen de URLs externas.
- El backend y PostgreSQL deben ejecutarse para usar el catálogo y las cuentas.
- Los tokens tienen una duración limitada y todavía no existen tokens de renovación.
- No hay recuperación de contraseña ni verificación de correo.
- No existen historial de entrenamiento, progreso ni rutinas personalizadas.
- **«Haz mi rutina»** todavía no está implementado.

## Próximos pasos

1. Agregar paginación incremental, búsqueda y filtros en Flutter.
2. Mejorar las pruebas de widgets y navegación.
3. Preparar el backend para despliegue y HTTPS.
4. Incorporar recuperación de contraseña y renovación de sesión.
5. Diseñar perfiles e historial de entrenamiento.
6. Diseñar y validar **«Haz mi rutina»** antes de integrar IA.

## Estado del proyecto

**V1.3 funcional:** catálogo bilingüe con PostgreSQL, autenticación opcional y favoritos persistentes por usuario.
