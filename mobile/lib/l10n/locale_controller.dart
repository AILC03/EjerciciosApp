import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleController extends ChangeNotifier {
  static const _preferenceKey = 'selected_language';
  static const supportedLanguageCodes = {'system', 'es', 'en'};

  Locale? _locale;

  Locale? get locale => _locale;

  String get selectedLanguageCode {
    return _locale?.languageCode ?? 'system';
  }

  Future<void> load() async {
    final preferences = await SharedPreferences.getInstance();
    final languageCode = preferences.getString(_preferenceKey);

    if (languageCode == null || languageCode == 'system') {
      _locale = null;
      return;
    }

    if (languageCode == 'es' || languageCode == 'en') {
      _locale = Locale(languageCode);
    }
  }

  Future<void> changeLanguage(String languageCode) async {
    if (!supportedLanguageCodes.contains(languageCode)) {
      throw ArgumentError.value(
        languageCode,
        'languageCode',
        'Idioma no soportado',
      );
    }

    final preferences = await SharedPreferences.getInstance();

    if (languageCode == 'system') {
      _locale = null;
      await preferences.remove(_preferenceKey);
    } else {
      _locale = Locale(languageCode);
      await preferences.setString(_preferenceKey, languageCode);
    }

    notifyListeners();
  }
}
