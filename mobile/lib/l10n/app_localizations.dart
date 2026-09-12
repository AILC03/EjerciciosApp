import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appName.
  ///
  /// In es, this message translates to:
  /// **'EjerciciosApp'**
  String get appName;

  /// No description provided for @chooseWorkout.
  ///
  /// In es, this message translates to:
  /// **'¿Qué quieres entrenar?'**
  String get chooseWorkout;

  /// No description provided for @chooseMuscleGroup.
  ///
  /// In es, this message translates to:
  /// **'Elige un grupo muscular'**
  String get chooseMuscleGroup;

  /// No description provided for @exerciseDetail.
  ///
  /// In es, this message translates to:
  /// **'Detalle del ejercicio'**
  String get exerciseDetail;

  /// No description provided for @instructions.
  ///
  /// In es, this message translates to:
  /// **'Instrucciones'**
  String get instructions;

  /// No description provided for @secondaryMuscles.
  ///
  /// In es, this message translates to:
  /// **'Músculos secundarios'**
  String get secondaryMuscles;

  /// No description provided for @noInstructions.
  ///
  /// In es, this message translates to:
  /// **'No hay instrucciones disponibles.'**
  String get noInstructions;

  /// No description provided for @gifUnavailable.
  ///
  /// In es, this message translates to:
  /// **'GIF no disponible'**
  String get gifUnavailable;

  /// No description provided for @refresh.
  ///
  /// In es, this message translates to:
  /// **'Actualizar'**
  String get refresh;

  /// No description provided for @retry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get retry;

  /// No description provided for @musclesLoadError.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar los músculos.'**
  String get musclesLoadError;

  /// No description provided for @exercisesLoadError.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar los ejercicios.'**
  String get exercisesLoadError;

  /// No description provided for @exerciseLoadError.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar el ejercicio.'**
  String get exerciseLoadError;

  /// No description provided for @noExercises.
  ///
  /// In es, this message translates to:
  /// **'No hay ejercicios disponibles.'**
  String get noExercises;

  /// No description provided for @selectAnotherMuscle.
  ///
  /// In es, this message translates to:
  /// **'Selecciona otro músculo e inténtalo nuevamente.'**
  String get selectAnotherMuscle;

  /// No description provided for @language.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get language;

  /// No description provided for @spanish.
  ///
  /// In es, this message translates to:
  /// **'Español'**
  String get spanish;

  /// No description provided for @english.
  ///
  /// In es, this message translates to:
  /// **'Inglés'**
  String get english;

  /// No description provided for @muscleAbductors.
  ///
  /// In es, this message translates to:
  /// **'Abductores'**
  String get muscleAbductors;

  /// No description provided for @muscleAbs.
  ///
  /// In es, this message translates to:
  /// **'Abdominales'**
  String get muscleAbs;

  /// No description provided for @muscleAdductors.
  ///
  /// In es, this message translates to:
  /// **'Aductores'**
  String get muscleAdductors;

  /// No description provided for @muscleBiceps.
  ///
  /// In es, this message translates to:
  /// **'Bíceps'**
  String get muscleBiceps;

  /// No description provided for @muscleCalves.
  ///
  /// In es, this message translates to:
  /// **'Pantorrillas'**
  String get muscleCalves;

  /// No description provided for @muscleCardiovascularSystem.
  ///
  /// In es, this message translates to:
  /// **'Sistema cardiovascular'**
  String get muscleCardiovascularSystem;

  /// No description provided for @muscleDelts.
  ///
  /// In es, this message translates to:
  /// **'Hombros'**
  String get muscleDelts;

  /// No description provided for @muscleForearms.
  ///
  /// In es, this message translates to:
  /// **'Antebrazos'**
  String get muscleForearms;

  /// No description provided for @muscleGlutes.
  ///
  /// In es, this message translates to:
  /// **'Glúteos'**
  String get muscleGlutes;

  /// No description provided for @muscleHamstrings.
  ///
  /// In es, this message translates to:
  /// **'Femorales'**
  String get muscleHamstrings;

  /// No description provided for @muscleLats.
  ///
  /// In es, this message translates to:
  /// **'Dorsales'**
  String get muscleLats;

  /// No description provided for @muscleLevatorScapulae.
  ///
  /// In es, this message translates to:
  /// **'Elevador de la escápula'**
  String get muscleLevatorScapulae;

  /// No description provided for @musclePectorals.
  ///
  /// In es, this message translates to:
  /// **'Pecho'**
  String get musclePectorals;

  /// No description provided for @muscleQuads.
  ///
  /// In es, this message translates to:
  /// **'Cuádriceps'**
  String get muscleQuads;

  /// No description provided for @muscleSerratusAnterior.
  ///
  /// In es, this message translates to:
  /// **'Serrato anterior'**
  String get muscleSerratusAnterior;

  /// No description provided for @muscleSpine.
  ///
  /// In es, this message translates to:
  /// **'Columna'**
  String get muscleSpine;

  /// No description provided for @muscleTraps.
  ///
  /// In es, this message translates to:
  /// **'Trapecios'**
  String get muscleTraps;

  /// No description provided for @muscleTriceps.
  ///
  /// In es, this message translates to:
  /// **'Tríceps'**
  String get muscleTriceps;

  /// No description provided for @muscleUpperBack.
  ///
  /// In es, this message translates to:
  /// **'Espalda superior'**
  String get muscleUpperBack;

  /// No description provided for @equipmentAssisted.
  ///
  /// In es, this message translates to:
  /// **'Asistido'**
  String get equipmentAssisted;

  /// No description provided for @equipmentBand.
  ///
  /// In es, this message translates to:
  /// **'Banda'**
  String get equipmentBand;

  /// No description provided for @equipmentBarbell.
  ///
  /// In es, this message translates to:
  /// **'Barra'**
  String get equipmentBarbell;

  /// No description provided for @equipmentBodyWeight.
  ///
  /// In es, this message translates to:
  /// **'Peso corporal'**
  String get equipmentBodyWeight;

  /// No description provided for @equipmentBosuBall.
  ///
  /// In es, this message translates to:
  /// **'Bosu'**
  String get equipmentBosuBall;

  /// No description provided for @equipmentCable.
  ///
  /// In es, this message translates to:
  /// **'Polea'**
  String get equipmentCable;

  /// No description provided for @equipmentDumbbell.
  ///
  /// In es, this message translates to:
  /// **'Mancuerna'**
  String get equipmentDumbbell;

  /// No description provided for @equipmentEllipticalMachine.
  ///
  /// In es, this message translates to:
  /// **'Máquina elíptica'**
  String get equipmentEllipticalMachine;

  /// No description provided for @equipmentEzBarbell.
  ///
  /// In es, this message translates to:
  /// **'Barra EZ'**
  String get equipmentEzBarbell;

  /// No description provided for @equipmentHammer.
  ///
  /// In es, this message translates to:
  /// **'Martillo'**
  String get equipmentHammer;

  /// No description provided for @equipmentKettlebell.
  ///
  /// In es, this message translates to:
  /// **'Pesa rusa'**
  String get equipmentKettlebell;

  /// No description provided for @equipmentLeverageMachine.
  ///
  /// In es, this message translates to:
  /// **'Máquina de palanca'**
  String get equipmentLeverageMachine;

  /// No description provided for @equipmentMedicineBall.
  ///
  /// In es, this message translates to:
  /// **'Balón medicinal'**
  String get equipmentMedicineBall;

  /// No description provided for @equipmentOlympicBarbell.
  ///
  /// In es, this message translates to:
  /// **'Barra olímpica'**
  String get equipmentOlympicBarbell;

  /// No description provided for @equipmentResistanceBand.
  ///
  /// In es, this message translates to:
  /// **'Banda de resistencia'**
  String get equipmentResistanceBand;

  /// No description provided for @equipmentRoller.
  ///
  /// In es, this message translates to:
  /// **'Rodillo'**
  String get equipmentRoller;

  /// No description provided for @equipmentRope.
  ///
  /// In es, this message translates to:
  /// **'Cuerda'**
  String get equipmentRope;

  /// No description provided for @equipmentSkiergMachine.
  ///
  /// In es, this message translates to:
  /// **'Máquina SkiErg'**
  String get equipmentSkiergMachine;

  /// No description provided for @equipmentSledMachine.
  ///
  /// In es, this message translates to:
  /// **'Trineo de entrenamiento'**
  String get equipmentSledMachine;

  /// No description provided for @equipmentSmithMachine.
  ///
  /// In es, this message translates to:
  /// **'Máquina Smith'**
  String get equipmentSmithMachine;

  /// No description provided for @equipmentStabilityBall.
  ///
  /// In es, this message translates to:
  /// **'Pelota de estabilidad'**
  String get equipmentStabilityBall;

  /// No description provided for @equipmentStationaryBike.
  ///
  /// In es, this message translates to:
  /// **'Bicicleta estática'**
  String get equipmentStationaryBike;

  /// No description provided for @equipmentStepmillMachine.
  ///
  /// In es, this message translates to:
  /// **'Máquina de escaleras'**
  String get equipmentStepmillMachine;

  /// No description provided for @equipmentTire.
  ///
  /// In es, this message translates to:
  /// **'Neumático'**
  String get equipmentTire;

  /// No description provided for @equipmentTrapBar.
  ///
  /// In es, this message translates to:
  /// **'Barra hexagonal'**
  String get equipmentTrapBar;

  /// No description provided for @equipmentUpperBodyErgometer.
  ///
  /// In es, this message translates to:
  /// **'Ergómetro de tren superior'**
  String get equipmentUpperBodyErgometer;

  /// No description provided for @equipmentWeighted.
  ///
  /// In es, this message translates to:
  /// **'Con peso'**
  String get equipmentWeighted;

  /// No description provided for @equipmentWheelRoller.
  ///
  /// In es, this message translates to:
  /// **'Rueda abdominal'**
  String get equipmentWheelRoller;

  /// No description provided for @muscleAbdominals.
  ///
  /// In es, this message translates to:
  /// **'Abdominales'**
  String get muscleAbdominals;

  /// No description provided for @muscleAnkleStabilizers.
  ///
  /// In es, this message translates to:
  /// **'Estabilizadores del tobillo'**
  String get muscleAnkleStabilizers;

  /// No description provided for @muscleAnkles.
  ///
  /// In es, this message translates to:
  /// **'Tobillos'**
  String get muscleAnkles;

  /// No description provided for @muscleBack.
  ///
  /// In es, this message translates to:
  /// **'Espalda'**
  String get muscleBack;

  /// No description provided for @muscleBrachialis.
  ///
  /// In es, this message translates to:
  /// **'Braquial'**
  String get muscleBrachialis;

  /// No description provided for @muscleChest.
  ///
  /// In es, this message translates to:
  /// **'Pecho'**
  String get muscleChest;

  /// No description provided for @muscleCore.
  ///
  /// In es, this message translates to:
  /// **'Zona media'**
  String get muscleCore;

  /// No description provided for @muscleDeltoids.
  ///
  /// In es, this message translates to:
  /// **'Deltoides'**
  String get muscleDeltoids;

  /// No description provided for @muscleFeet.
  ///
  /// In es, this message translates to:
  /// **'Pies'**
  String get muscleFeet;

  /// No description provided for @muscleGripMuscles.
  ///
  /// In es, this message translates to:
  /// **'Músculos de agarre'**
  String get muscleGripMuscles;

  /// No description provided for @muscleGroin.
  ///
  /// In es, this message translates to:
  /// **'Ingle'**
  String get muscleGroin;

  /// No description provided for @muscleHands.
  ///
  /// In es, this message translates to:
  /// **'Manos'**
  String get muscleHands;

  /// No description provided for @muscleHipFlexors.
  ///
  /// In es, this message translates to:
  /// **'Flexores de la cadera'**
  String get muscleHipFlexors;

  /// No description provided for @muscleInnerThighs.
  ///
  /// In es, this message translates to:
  /// **'Parte interna de los muslos'**
  String get muscleInnerThighs;

  /// No description provided for @muscleLatissimusDorsi.
  ///
  /// In es, this message translates to:
  /// **'Dorsal ancho'**
  String get muscleLatissimusDorsi;

  /// No description provided for @muscleLowerAbs.
  ///
  /// In es, this message translates to:
  /// **'Abdominales inferiores'**
  String get muscleLowerAbs;

  /// No description provided for @muscleLowerBack.
  ///
  /// In es, this message translates to:
  /// **'Espalda baja'**
  String get muscleLowerBack;

  /// No description provided for @muscleObliques.
  ///
  /// In es, this message translates to:
  /// **'Oblicuos'**
  String get muscleObliques;

  /// No description provided for @muscleQuadriceps.
  ///
  /// In es, this message translates to:
  /// **'Cuádriceps'**
  String get muscleQuadriceps;

  /// No description provided for @muscleRearDeltoids.
  ///
  /// In es, this message translates to:
  /// **'Deltoides posteriores'**
  String get muscleRearDeltoids;

  /// No description provided for @muscleRhomboids.
  ///
  /// In es, this message translates to:
  /// **'Romboides'**
  String get muscleRhomboids;

  /// No description provided for @muscleRotatorCuff.
  ///
  /// In es, this message translates to:
  /// **'Manguito rotador'**
  String get muscleRotatorCuff;

  /// No description provided for @muscleShins.
  ///
  /// In es, this message translates to:
  /// **'Tibiales'**
  String get muscleShins;

  /// No description provided for @muscleShoulders.
  ///
  /// In es, this message translates to:
  /// **'Hombros'**
  String get muscleShoulders;

  /// No description provided for @muscleSoleus.
  ///
  /// In es, this message translates to:
  /// **'Sóleo'**
  String get muscleSoleus;

  /// No description provided for @muscleSternocleidomastoid.
  ///
  /// In es, this message translates to:
  /// **'Esternocleidomastoideo'**
  String get muscleSternocleidomastoid;

  /// No description provided for @muscleTrapezius.
  ///
  /// In es, this message translates to:
  /// **'Trapecio'**
  String get muscleTrapezius;

  /// No description provided for @muscleUpperChest.
  ///
  /// In es, this message translates to:
  /// **'Pecho superior'**
  String get muscleUpperChest;

  /// No description provided for @muscleWristExtensors.
  ///
  /// In es, this message translates to:
  /// **'Extensores de la muñeca'**
  String get muscleWristExtensors;

  /// No description provided for @muscleWristFlexors.
  ///
  /// In es, this message translates to:
  /// **'Flexores de la muñeca'**
  String get muscleWristFlexors;

  /// No description provided for @muscleWrists.
  ///
  /// In es, this message translates to:
  /// **'Muñecas'**
  String get muscleWrists;

  /// No description provided for @systemLanguage.
  ///
  /// In es, this message translates to:
  /// **'Idioma del dispositivo'**
  String get systemLanguage;

  /// No description provided for @loginTitle.
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Accede para guardar tus ejercicios favoritos'**
  String get loginSubtitle;

  /// No description provided for @email.
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico'**
  String get email;

  /// No description provided for @password.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get password;

  /// No description provided for @login.
  ///
  /// In es, this message translates to:
  /// **'Entrar'**
  String get login;

  /// No description provided for @createAccount.
  ///
  /// In es, this message translates to:
  /// **'Crear una cuenta'**
  String get createAccount;

  /// No description provided for @emailRequired.
  ///
  /// In es, this message translates to:
  /// **'Ingresa tu correo electrónico'**
  String get emailRequired;

  /// No description provided for @emailInvalid.
  ///
  /// In es, this message translates to:
  /// **'Ingresa un correo electrónico válido'**
  String get emailInvalid;

  /// No description provided for @passwordRequired.
  ///
  /// In es, this message translates to:
  /// **'Ingresa tu contraseña'**
  String get passwordRequired;

  /// No description provided for @passwordTooShort.
  ///
  /// In es, this message translates to:
  /// **'La contraseña debe tener al menos 8 caracteres'**
  String get passwordTooShort;

  /// No description provided for @registerTitle.
  ///
  /// In es, this message translates to:
  /// **'Crear cuenta'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Crea una cuenta para guardar tus ejercicios favoritos'**
  String get registerSubtitle;

  /// No description provided for @confirmPassword.
  ///
  /// In es, this message translates to:
  /// **'Confirmar contraseña'**
  String get confirmPassword;

  /// No description provided for @confirmPasswordRequired.
  ///
  /// In es, this message translates to:
  /// **'Confirma tu contraseña'**
  String get confirmPasswordRequired;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In es, this message translates to:
  /// **'Las contraseñas no coinciden'**
  String get passwordsDoNotMatch;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In es, this message translates to:
  /// **'¿Ya tienes una cuenta?'**
  String get alreadyHaveAccount;

  /// No description provided for @backToLogin.
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión'**
  String get backToLogin;

  /// No description provided for @logout.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get logout;

  /// No description provided for @logoutConfirmation.
  ///
  /// In es, this message translates to:
  /// **'¿Quieres cerrar tu sesión?'**
  String get logoutConfirmation;

  /// No description provided for @cancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
