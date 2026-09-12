# Aplicación Flutter de EjerciciosApp

Cliente móvil y web de EjerciciosApp. Permite consultar ejercicios por músculo sin iniciar sesión y ofrece autenticación opcional para guardar favoritos personales.

## Funcionalidades de la V1.3

- Selección visual del músculo que se desea entrenar.
- Lista de ejercicios filtrada por músculo principal.
- Detalle con GIF, equipo, músculos e instrucciones.
- Español, inglés e idioma automático del dispositivo.
- Tema oscuro, skeletons y caché multimedia.
- Registro, inicio y cierre de sesión.
- Recuperación automática de una sesión guardada.
- Favoritos desde las tarjetas y desde el detalle.
- Pantalla de favoritos agrupados por músculo en menús desplegables.

El catálogo es público. Si una persona intenta guardar un ejercicio sin sesión, la aplicación abre el flujo de autenticación.

## Flujo de pantallas

```text
Selección de músculos
        │
        ├── Músculo → Lista de ejercicios → Detalle
        │                                  └── Favorito
        │
        ├── Cuenta → Login ↔ Registro
        │
        └── Mis favoritos → Grupos desplegables → Detalle
```

## Pantallas

### Selección de músculos

- Es la pantalla inicial para usuarios con o sin cuenta.
- Solicita `GET /api/v1/muscles`.
- Muestra imágenes locales y nombres traducidos.
- Permite cambiar el idioma.
- Muestra acceso a la cuenta o cierre de sesión.
- Muestra el acceso a favoritos cuando existe una sesión.

### Ejercicios

- Solicita `GET /api/v1/exercises?muscle=...`.
- Muestra imagen, nombre, equipo y corazón en cada tarjeta.
- Abre el login si un invitado intenta guardar un favorito.
- Agrega o elimina el favorito inmediatamente cuando hay sesión.

### Detalle

- Solicita `GET /api/v1/exercises/{id}`.
- Presenta nombre, GIF, equipo, músculos e instrucciones.
- Elige instrucciones según el idioma activo y aplica un idioma de respaldo.
- Permite agregar o quitar el ejercicio de favoritos.

### Autenticación

- `LoginScreen` inicia sesión con correo y contraseña.
- `RegisterScreen` crea una cuenta.
- `AuthFlowScreen` permite alternar entre ambas pantallas.
- `AuthGate` espera la restauración inicial de la sesión sin impedir el uso público del catálogo.

### Favoritos

- Solicita `GET /api/v1/favorites` con el JWT.
- Agrupa los ejercicios por `target`, que representa el músculo principal usado por el catálogo.
- Cada músculo se muestra mediante un `ExpansionTile`.
- Permite abrir el detalle o retirar el favorito.

## Arquitectura interna

```text
Pantallas y widgets
        │ acciones del usuario
        ▼
Controllers (Provider)
        │ coordinan estado
        ▼
Services
        │ HTTP/JSON
        ▼
FastAPI
```

### Controllers

- `AuthController`: inicializa, registra, inicia y cierra la sesión; expone el usuario y los estados de carga/error.
- `FavoritesController`: carga la colección del usuario, reconoce qué ejercicios están guardados y coordina altas y bajas.
- `LocaleController`: administra y conserva el idioma seleccionado.

`main.dart` registra los controllers con Provider. `FavoritesController` observa a `AuthController`: carga favoritos al iniciar sesión y los limpia al cerrarla.

### Services

- `ExerciseService`: consulta músculos, listas y detalles.
- `AuthService`: realiza registro, login y consulta del usuario actual.
- `FavoriteService`: lista, agrega y elimina favoritos.
- `TokenStorage`: guarda y recupera el JWT mediante almacenamiento seguro.
- `ApiException`: representa errores HTTP que la interfaz puede mostrar.

### Models

- `Muscle`: valor de la API, traducción e imagen local.
- `Exercise`: resumen utilizado en tarjetas.
- `ExerciseDetail`: información completa y conversión a `Exercise` para favoritos.
- `User`: usuario autenticado.
- `AuthToken`: token recibido durante el login.

## Estructura

```text
mobile/
├── assets/images/muscles/
├── lib/
│   ├── main.dart
│   ├── config/
│   │   └── api_config.dart
│   ├── controllers/
│   │   ├── auth_controller.dart
│   │   └── favorites_controller.dart
│   ├── l10n/
│   │   ├── app_es.arb
│   │   ├── app_en.arb
│   │   ├── exercise_labels.dart
│   │   └── locale_controller.dart
│   ├── models/
│   ├── screens/
│   │   ├── auth/
│   │   ├── muscle_selection_screen.dart
│   │   ├── exercise_screen.dart
│   │   ├── exercise_detail_screen.dart
│   │   └── favorites_screen.dart
│   ├── services/
│   ├── theme/
│   └── widgets/
├── test/
├── web/
├── pubspec.yaml
└── README.md
```

## Tecnologías y paquetes

| Paquete | Uso |
|---|---|
| Flutter y Material | Interfaz y navegación |
| `provider` | Estado compartido |
| `http` | Peticiones a FastAPI |
| `flutter_secure_storage` | Persistencia del token |
| `cached_network_image` | Caché de imágenes y GIF |
| `skeletonizer` | Estados visuales de carga |
| `flutter_localizations` e `intl` | Traducciones |
| `shared_preferences` | Preferencia de idioma |
| `flutter_test` | Pruebas automatizadas |

Las versiones exactas se encuentran en `pubspec.yaml` y `pubspec.lock`.

## Configuración de la API

`lib/config/api_config.dart` obtiene la URL mediante una variable de compilación:

```dart
const String.fromEnvironment('API_BASE_URL')
```

Si no se proporciona, usa `http://10.0.2.2:8000`.

| Entorno | Dirección |
|---|---|
| Emulador Android | `http://10.0.2.2:8000` |
| Chrome en la misma PC | `http://127.0.0.1:8000` |
| Teléfono físico | `http://IP_LOCAL_DE_LA_PC:8000` |

Android:

```powershell
flutter run -d emulator-5554
```

Chrome:

```powershell
flutter run -d chrome --web-port 5173 --dart-define=API_BASE_URL=http://127.0.0.1:8000
```

Teléfono físico:

```powershell
flutter run -d ID_DEL_TELEFONO --dart-define=API_BASE_URL=http://IP_LOCAL_DE_LA_PC:8000
```

Para un teléfono físico, el backend debe iniciarse con `--host 0.0.0.0`, ambos dispositivos deben compartir red y el firewall debe permitir el puerto 8000.

## Sesión y seguridad

1. `AuthService` recibe el JWT del backend.
2. `TokenStorage` lo guarda con `flutter_secure_storage`.
3. Al abrir la aplicación, `AuthController` intenta recuperar el token.
4. `/api/v1/auth/me` confirma si sigue siendo válido.
5. `FavoriteService` añade `Authorization: Bearer ...` a sus peticiones.
6. Al cerrar sesión se elimina el token y se vacían los favoritos locales.

El cliente no guarda la contraseña. La validación definitiva de identidad siempre ocurre en el backend.

## Internacionalización

Los archivos fuente son:

- `lib/l10n/app_es.arb`
- `lib/l10n/app_en.arb`

Después de modificarlos:

```powershell
flutter gen-l10n
```

Los archivos `app_localizations*.dart` son generados y no deben editarse manualmente. Los nombres de ejercicios permanecen en inglés cuando el dataset no proporciona traducciones.

## Carga, errores y caché

- Los skeletons representan la forma del contenido mientras responde la API.
- `CachedNetworkImage` conserva recursos para reducir descargas posteriores.
- Una imagen o GIF que falla muestra un reemplazo visual.
- Las pantallas ofrecen reintento cuando falla la petición principal.
- Los botones de favorito muestran un indicador durante la actualización.

## Instalación

Con Flutter configurado y el backend activo:

```powershell
flutter pub get
flutter doctor
flutter devices
flutter run -d emulator-5554
```

Después de agregar dependencias, recursos o clases generadas, realiza un reinicio completo de la aplicación.

## Verificación

```powershell
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

Las pruebas cubren modelos, traducciones, preferencia de idioma, servicios de autenticación, recuperación de sesión, servicio de favoritos y lógica de `FavoritesController`.

## Prueba manual recomendada

1. Abrir el catálogo como invitado.
2. Intentar guardar un ejercicio y comprobar que aparezca el login.
3. Registrar una cuenta o iniciar sesión.
4. Agregar favoritos desde una tarjeta y desde el detalle.
5. Abrir “Mis favoritos” y desplegar cada músculo.
6. Eliminar un favorito y verificar que desaparezca en todas las pantallas.
7. Cerrar sesión y confirmar que el catálogo siga disponible.
8. Reiniciar la aplicación y comprobar la recuperación de una sesión válida.

## Decisiones de diseño

- La autenticación es opcional para conservar un acceso rápido al catálogo.
- Provider es suficiente para el estado compartido de esta versión.
- Se usan modelos distintos para lista y detalle para reducir datos innecesarios.
- Las imágenes musculares son locales; las imágenes y GIF de ejercicios son remotos.
- Los favoritos se guardan en PostgreSQL, no solamente en el dispositivo.
- La URL del backend se configura por ambiente sin editar el código fuente.

## Limitaciones

- La lista solicita actualmente la primera página de hasta 20 ejercicios.
- Los recursos multimedia dependen de servicios externos.
- No hay recuperación de contraseña ni renovación automática del token.
- No existe modo sin conexión completo.
- La generación de rutinas con IA todavía no está implementada.
