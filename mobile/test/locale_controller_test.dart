import 'package:ejercicios_app/l10n/locale_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('usa el idioma del sistema sin una preferencia guardada', () async {
    final controller = LocaleController();

    await controller.load();

    expect(controller.locale, isNull);
    expect(controller.selectedLanguageCode, 'system');
  });

  test('carga una preferencia guardada', () async {
    SharedPreferences.setMockInitialValues({'selected_language': 'en'});
    final controller = LocaleController();

    await controller.load();

    expect(controller.locale?.languageCode, 'en');
    expect(controller.selectedLanguageCode, 'en');
  });

  test('guarda el idioma seleccionado', () async {
    final controller = LocaleController();

    await controller.changeLanguage('es');
    final preferences = await SharedPreferences.getInstance();

    expect(controller.locale?.languageCode, 'es');
    expect(preferences.getString('selected_language'), 'es');
  });

  test('volver al sistema elimina la preferencia', () async {
    SharedPreferences.setMockInitialValues({'selected_language': 'en'});
    final controller = LocaleController();
    await controller.load();

    await controller.changeLanguage('system');
    final preferences = await SharedPreferences.getInstance();

    expect(controller.locale, isNull);
    expect(preferences.containsKey('selected_language'), isFalse);
  });

  test('rechaza idiomas no soportados', () async {
    final controller = LocaleController();

    expect(() => controller.changeLanguage('fr'), throwsArgumentError);
  });
}
