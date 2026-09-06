# Aplicación móvil de EjerciciosApp

Cliente móvil desarrollado con Flutter. Muestra los grupos musculares disponibles, consulta al backend los ejercicios correspondientes y presenta el detalle de cada ejercicio.

La versión 1.1 incorpora una interfaz bilingüe en español e inglés, detección del idioma del dispositivo y selección manual persistente.

## Experiencia de usuario

```text
Inicio → Selección de músculo → Lista filtrada → Detalle del ejercicio
```

La aplicación no abre un catálogo sin filtro: la primera decisión del usuario es el músculo que desea entrenar.

### Pantalla de músculos

- Solicita `GET /api/v1/muscles`.
- Traduce los valores técnicos al idioma activo.
- Asocia cada músculo con una imagen de `assets/images/muscles/`.
- Abre la lista filtrada al pulsar una tarjeta.

### Pantalla de ejercicios

- Solicita `GET /api/v1/exercises?muscle=...`.
- Muestra imagen, nombre y equipo en cada tarjeta.
- Conserva las imágenes en caché.
- Abre el detalle utilizando el ID del ejercicio.

### Pantalla de detalle

- Solicita `GET /api/v1/exercises/{id}`.
- Presenta nombre, GIF, equipo y músculo principal.
- Incluye músculos secundarios cuando existen.
- Muestra instrucciones según el idioma activo y utiliza el otro idioma como respaldo.
- Muestra la atribución proporcionada por el dataset.

## Estados de interfaz

Cada pantalla contempla:

- **Carga:** skeletons con la forma aproximada del contenido.
- **Contenido:** información recibida correctamente.
- **Vacío:** mensaje cuando no hay ejercicios.
- **Error:** explicación y botón para reintentar.
- **Error multimedia:** icono alternativo para imágenes o GIF no disponibles.

Los skeletons generales aparecen mientras responde la API. Cada imagen y GIF tiene además su propio skeleton, por lo que un solo recurso multimedia no bloquea el resto de la pantalla.

## Tecnologías y paquetes

| Paquete | Uso |
|---|---|
| Flutter / Material | Interfaz, tema y navegación |
| `http` | Peticiones HTTP a FastAPI |
| `cached_network_image` | Caché y estados multimedia |
| `skeletonizer` | Estados visuales de carga |
| `flutter_localizations` / `intl` | Generación y aplicación de traducciones |
| `shared_preferences` | Persistencia del idioma seleccionado |
| `flutter_test` | Pruebas automatizadas |

Las versiones exactas se encuentran en `pubspec.yaml` y `pubspec.lock`.

## Estructura

```text
mobile/
├── assets/images/muscles/       Imágenes locales de músculos
├── lib/
│   ├── main.dart                Inicio de MaterialApp
│   ├── l10n/
│   │   ├── app_es.arb           Textos en español
│   │   ├── app_en.arb           Textos en inglés
│   │   ├── exercise_labels.dart Traducción de valores del dataset
│   │   └── locale_controller.dart Idioma activo y persistencia
│   ├── models/
│   │   ├── muscle.dart          Traducciones y rutas de imágenes
│   │   ├── exercise.dart        Modelo resumido para tarjetas
│   │   └── exercise_detail.dart Modelo completo e instrucciones
│   ├── screens/
│   │   ├── muscle_selection_screen.dart
│   │   ├── exercise_screen.dart
│   │   └── exercise_detail_screen.dart
│   ├── services/
│   │   └── exercise_service.dart Cliente HTTP y conversión JSON
│   ├── theme/
│   │   └── app_theme.dart       Paleta oscura y estilos globales
│   └── widgets/
│       ├── exercise_card.dart   Tarjeta reutilizable
│       └── loading_skeletons.dart Estados de carga
├── test/widget_test.dart        Pruebas de modelos
├── pubspec.yaml                 Dependencias y recursos
└── README.md
```

## Flujo interno

1. Una pantalla llama a `ExerciseService`.
2. El servicio construye la URL y realiza la petición con un límite de 15 segundos.
3. Una respuesta distinta de `200` se convierte en una excepción.
4. El cuerpo UTF-8 se decodifica desde JSON.
5. `Muscle`, `Exercise` o `ExerciseDetail` convierten los campos.
6. El `FutureBuilder` cambia del skeleton a contenido, vacío o error.
7. `CachedNetworkImage` descarga y almacena la multimedia.

## Internacionalización

El botón de idioma de la pantalla principal ofrece tres opciones:

- Idioma del dispositivo.
- Español.
- English.

`LocaleController` guarda la selección mediante `shared_preferences` y reconstruye `MaterialApp` al cambiarla. Los archivos ARB son la fuente de los textos; los archivos `app_localizations*.dart` son generados por Flutter y no deben editarse manualmente.

```powershell
flutter gen-l10n
```

La localización cubre la interfaz, músculos, equipos e instrucciones. Los nombres de los ejercicios permanecen en inglés porque el dataset actual no proporciona traducciones revisadas para ese campo.

## Configuración del backend

La URL está definida en `lib/services/exercise_service.dart`:

```dart
static const baseUrl = 'http://10.0.2.2:8000';
```

| Entorno | Dirección sugerida |
|---|---|
| Emulador Android | `http://10.0.2.2:8000` |
| Flutter Web en la misma PC | `http://127.0.0.1:8000` |
| Teléfono físico | `http://IP_LOCAL_DE_LA_PC:8000` |

Para un teléfono físico, inicia el backend de forma accesible en la red:

```powershell
python -m uvicorn app.main:app --reload --host 0.0.0.0
```

La computadora y el teléfono deben compartir red y el firewall debe permitir el puerto 8000.

## Instalación y ejecución

Primero inicia el backend. Después, desde `mobile`:

```powershell
flutter pub get
flutter doctor
flutter devices
flutter run -d emulator-5554
```

Sustituye `emulator-5554` por el identificador mostrado por `flutter devices`. Si agregas recursos o dependencias, realiza un reinicio completo en lugar de depender únicamente de hot reload.

## Verificación

```powershell
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

Las pruebas incluyen conversión de modelos, selección y respaldo de instrucciones, traducción de etiquetas y persistencia del idioma.

## Imágenes de músculos

Los archivos deben estar en `assets/images/muscles/` y usar el valor de la API en minúsculas, reemplazando espacios por guiones bajos:

```text
pectorals         → pectorals.png
upper back        → upper_back.png
serratus anterior → serratus_anterior.png
```

La carpeta completa está declarada como recurso en `pubspec.yaml`.

## Decisiones de diseño

- Tema oscuro verde azulado con acento amarillo.
- Material Design sin una biblioteca completa de componentes externa.
- Navegación con `Navigator` y `MaterialPageRoute`, suficiente para la V1.
- Modelos distintos para lista y detalle para no cargar instrucciones en cada tarjeta.
- Imágenes musculares locales para una pantalla inicial estable.
- Multimedia de ejercicios remota con caché para reducir descargas repetidas.

## Problemas frecuentes

### El health funciona en Windows, pero no en Android

En el emulador, `localhost` apunta al propio emulador. Usa `10.0.2.2` para llegar a Windows.

### No aparece una imagen muscular

Comprueba el nombre y extensión, confirma que esté bajo `assets/images/muscles/`, ejecuta `flutter pub get` y reinicia completamente la app.

### La API no responde

Verifica que Uvicorn esté activo, abre `/health`, confirma la dirección configurada y revisa el firewall.

### El GIF tarda en mostrarse

La primera descarga depende de la red y del servidor multimedia. Durante la espera se muestra un skeleton; visitas posteriores pueden aprovechar la caché.

## Alcance futuro

- Paginación o scroll infinito.
- Búsqueda y filtros adicionales.
- Favoritos y almacenamiento local.
- Configuración de API por ambiente.
- Pruebas de navegación y peticiones HTTP simuladas.
- Integración futura de **«Haz mi rutina»**, todavía fuera de la V1.
