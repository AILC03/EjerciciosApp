# EjerciciosApp

Aplicación móvil universitaria para consultar un catálogo de ejercicios agrupados por músculo principal. El usuario elige la zona que desea entrenar, consulta sus ejercicios y abre una ficha con información detallada, GIF e instrucciones.

La primera versión es un catálogo de solo lectura. La generación inteligente de rutinas, identificada como **«Haz mi rutina»**, forma parte de una versión futura y todavía no está implementada.

## Funcionalidades de la V1.2

- Selección visual de 19 grupos musculares.
- Consulta de ejercicios filtrados por músculo principal.
- Tarjetas con imagen, nombre y equipo requerido.
- Detalle con GIF, equipo, músculo objetivo, músculos secundarios e instrucciones.
- Interfaz disponible en español e inglés.
- Detección automática del idioma del dispositivo.
- Selector manual de idioma con preferencia persistente.
- Traducción de músculos, equipos y mensajes de la interfaz.
- Instrucciones según el idioma activo, con respaldo si una traducción no existe.
- Tema oscuro y estados de carga mediante skeletons.
- Caché de imágenes y manejo de errores de red.
- API documentada automáticamente con OpenAPI/Swagger.
- Pruebas automatizadas en backend y aplicación móvil.

## Arquitectura general

```text
Aplicación Flutter
       │ HTTP/JSON
       ▼
API REST FastAPI
       │
       ├── Routes: recibe y valida peticiones
       ├── Services: filtros, búsqueda y paginación
       └── Repository: carga el catálogo
                    │
                    ▼
              PostgreSQL
```

El repositorio es un monorepositorio con dos aplicaciones:

```text
EjerciciosApp/
├── backend/             API REST con FastAPI y Python
│   ├── app/
│   ├── data/
│   ├── test/
│   ├── README.md
│   └── requirements.txt
├── mobile/              Aplicación móvil con Flutter y Dart
│   ├── assets/
│   ├── lib/
│   ├── test/
│   ├── README.md
│   └── pubspec.yaml
├── .gitignore
└── README.md
```

La documentación específica está en [backend/README.md](backend/README.md) y [mobile/README.md](mobile/README.md).

## Tecnologías

| Componente | Tecnología | Responsabilidad |
|---|---|---|
| Aplicación móvil | Flutter y Dart | Interfaz y navegación móvil |
| Cliente HTTP | `http` | Comunicación con la API |
| Imágenes | `cached_network_image` | Descarga y caché multimedia |
| Carga visual | `skeletonizer` | Placeholders animados |
| Preferencias | `shared_preferences` | Persistencia del idioma seleccionado |
| Localización | Flutter Intl/ARB | Interfaz en español e inglés |
| Backend | Python y FastAPI | API, validación y lógica |
| Servidor | Uvicorn | Ejecución de FastAPI |
| Modelos | Pydantic | Validación de respuestas |
| Base de datos | PostgreSQL | Persistencia del catálogo |
| ORM | SQLAlchemy | Modelos y consultas de datos |
| Controlador | Psycopg | Comunicación con PostgreSQL |
| Migraciones | Alembic | Versionado del esquema |
| Dataset inicial | JSON | Fuente utilizada por el seed |
| Pruebas | Pytest y Flutter Test | Verificación automática |

## Requisitos

- Git.
- Python 3.12 o una versión compatible con las dependencias.
- Flutter SDK con soporte para Android.
- Android Studio, Android SDK y un emulador, o un dispositivo Android físico.
- PostgreSQL.

Para desarrollar para iOS se requiere macOS y Xcode. Un emulador de iPhone no puede ejecutarse oficialmente desde Windows.

## Instalación

### 1. Clonar el repositorio

```powershell
git clone https://github.com/AILC03/EjerciciosApp.git
cd EjerciciosApp
```

### 2. Ejecutar el backend

```powershell
cd backend
python -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install -r requirements.txt
Copy-Item .env.example .env
alembic upgrade head
python -m scripts.seed_exercises
python -m uvicorn app.main:app --reload
```

Servicios locales:

- API: `http://127.0.0.1:8000`
- Estado: `http://127.0.0.1:8000/health`
- Swagger: `http://127.0.0.1:8000/docs`

### 3. Ejecutar la aplicación móvil

En otra terminal:

```powershell
cd mobile
flutter pub get
flutter devices
flutter run -d emulator-5554
```

El identificador del emulador puede ser diferente. Se debe utilizar el mostrado por `flutter devices`.

## Comunicación local

La aplicación utiliza actualmente esta dirección en `mobile/lib/services/exercise_service.dart`:

```dart
static const baseUrl = 'http://10.0.2.2:8000';
```

`10.0.2.2` permite que el emulador Android alcance el `localhost` de Windows. Para un teléfono físico debe sustituirse por la dirección IPv4 local de la computadora; ambos dispositivos deben estar en la misma red y el backend debe aceptar conexiones de red.

## API principal

| Método | Ruta | Descripción |
|---|---|---|
| GET | `/health` | Comprueba el estado del backend |
| GET | `/api/v1/muscles` | Lista los músculos disponibles |
| GET | `/api/v1/exercises` | Lista, filtra, busca y pagina ejercicios |
| GET | `/api/v1/exercises/{id}` | Devuelve el detalle de un ejercicio |
| GET | `/api/v1/equipment` | Lista los equipos disponibles |
| GET | `/api/v1/body-parts` | Lista las partes del cuerpo |

Ejemplo:

```http
GET /api/v1/exercises?muscle=pectorals&page=1&page_size=20
```

## Flujo de uso

1. Flutter solicita los músculos a la API.
2. La pantalla inicial los muestra con una imagen local.
3. El usuario selecciona un músculo.
4. Flutter solicita los ejercicios filtrados.
5. La API consulta PostgreSQL mediante SQLAlchemy y devuelve JSON paginado.
6. Flutter presenta las tarjetas y conserva en caché las imágenes.
7. Al seleccionar una tarjeta, la aplicación solicita el detalle por ID.
8. La ficha muestra el GIF y las instrucciones disponibles.

## Pruebas y calidad

Backend:

```powershell
cd backend
python -m pytest -v
```

Aplicación móvil:

```powershell
cd mobile
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

## Fuente de datos

El catálogo `backend/data/exercises.json` y sus recursos multimedia proceden de [`hasaneyldrm/exercises-dataset`](https://github.com/hasaneyldrm/exercises-dataset). La aplicación conserva el campo de atribución incluido en los registros. Antes de distribuir comercialmente el producto deben revisarse la licencia y las condiciones del dataset y de sus imágenes.

## Limitaciones

- No hay autenticación, perfiles ni seguimiento de progreso.
- No se crean, modifican ni eliminan ejercicios.
- PostgreSQL debe estar activo para ejecutar el backend.
- Las imágenes y los GIF dependen de recursos externos.
- La aplicación muestra la primera página de hasta 20 ejercicios por músculo.
- La dirección del backend se configura actualmente en el código.
- Los nombres propios de los ejercicios se conservan en inglés porque el dataset no incluye nombres traducidos.
- La generación de rutinas con IA no está implementada.

## Próximos pasos

1. Extraer la URL de la API móvil a configuración por entorno.
2. Incorporar paginación o carga incremental en Flutter.
3. Agregar búsqueda y filtros por equipo.
4. Mejorar cobertura de pruebas de widgets y servicios.
5. Preparar despliegue del backend y configuración de producción.
6. Evaluar usuarios, favoritos e historial de entrenamiento.
7. Diseñar y validar la futura función **«Haz mi rutina»**.

## Idiomas

La aplicación permite usar español, inglés o el idioma del dispositivo. La selección se guarda localmente y se restaura al volver a abrirla. Los textos de interfaz, músculos, equipos e instrucciones se localizan; los nombres de los ejercicios permanecen en su inglés original durante la V1.1.

## Estado del proyecto

V1.2 funcional: catálogo móvil bilingüe respaldado por PostgreSQL, SQLAlchemy y migraciones Alembic. Continúa orientada a demostración académica y desarrollo local.
