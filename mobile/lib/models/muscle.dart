class Muscle {
  final String apiValue;
  final String label;

  const Muscle({required this.apiValue, required this.label});

  String get imagePath {
    final filename = apiValue.replaceAll(' ', '_');

    return 'assets/images/muscles/$filename.png';
  }

  static const Map<String, String> labels = {
    'abductors': 'Abductores',
    'abs': 'Abdominales',
    'adductors': 'Aductores',
    'biceps': 'Bíceps',
    'calves': 'Pantorrillas',
    'cardiovascular system': 'Cardiovascular',
    'delts': 'Hombros',
    'forearms': 'Antebrazos',
    'glutes': 'Glúteos',
    'hamstrings': 'Femorales',
    'lats': 'Dorsales',
    'levator scapulae': 'Elevador de la escápula',
    'pectorals': 'Pecho',
    'quads': 'Cuádriceps',
    'serratus anterior': 'Serrato anterior',
    'spine': 'Columna',
    'traps': 'Trapecios',
    'triceps': 'Tríceps',
    'upper back': 'Espalda superior',
  };

  factory Muscle.fromApi(String value) {
    return Muscle(apiValue: value, label: labels[value] ?? value);
  }
}
