import 'package:ejercicios_app/l10n/app_localizations_en.dart';
import 'package:ejercicios_app/l10n/app_localizations_es.dart';
import 'package:ejercicios_app/l10n/exercise_labels.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Etiquetas localizadas del catálogo', () {
    final spanish = AppLocalizationsEs();
    final english = AppLocalizationsEn();

    test('traduce equipos al idioma activo', () {
      expect(spanish.equipmentLabel('dumbbell'), 'Mancuerna');
      expect(english.equipmentLabel('dumbbell'), 'Dumbbell');
    });

    test('traduce músculos al idioma activo', () {
      expect(spanish.muscleLabel('pectorals'), 'Pecho');
      expect(english.muscleLabel('pectorals'), 'Chest');
      expect(spanish.muscleLabel('lower back'), 'Espalda baja');
    });

    test('normaliza mayúsculas y espacios', () {
      expect(spanish.equipmentLabel('  BARBELL  '), 'Barra');
      expect(english.muscleLabel('  UPPER BACK  '), 'Upper back');
    });

    test('conserva valores desconocidos', () {
      expect(spanish.equipmentLabel('new machine'), 'new machine');
      expect(english.muscleLabel('new muscle'), 'new muscle');
    });
  });
}
