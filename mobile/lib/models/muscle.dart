import '../l10n/app_localizations.dart';

class Muscle {
  final String apiValue;

  const Muscle({required this.apiValue});

  String get imagePath {
    final filename = apiValue.replaceAll(' ', '_');

    return 'assets/images/muscles/$filename.png';
  }

  String localizedLabel(AppLocalizations texts) {
    return switch (apiValue) {
      'abductors' => texts.muscleAbductors,
      'abs' => texts.muscleAbs,
      'adductors' => texts.muscleAdductors,
      'biceps' => texts.muscleBiceps,
      'calves' => texts.muscleCalves,
      'cardiovascular system' => texts.muscleCardiovascularSystem,
      'delts' => texts.muscleDelts,
      'forearms' => texts.muscleForearms,
      'glutes' => texts.muscleGlutes,
      'hamstrings' => texts.muscleHamstrings,
      'lats' => texts.muscleLats,
      'levator scapulae' => texts.muscleLevatorScapulae,
      'pectorals' => texts.musclePectorals,
      'quads' => texts.muscleQuads,
      'serratus anterior' => texts.muscleSerratusAnterior,
      'spine' => texts.muscleSpine,
      'traps' => texts.muscleTraps,
      'triceps' => texts.muscleTriceps,
      'upper back' => texts.muscleUpperBack,
      _ => apiValue,
    };
  }

  factory Muscle.fromApi(String value) {
    return Muscle(apiValue: value);
  }
}
