import 'exercise.dart';

class ExerciseDetail {
  final String id;
  final String name;
  final String target;
  final String equipment;
  final String muscleGroup;
  final List<String> secondaryMuscles;
  final Map<String, List<String>> instructionSteps;
  final String image;
  final String gifUrl;
  final String attribution;

  const ExerciseDetail({
    required this.id,
    required this.name,
    required this.target,
    required this.equipment,
    required this.muscleGroup,
    required this.secondaryMuscles,
    required this.instructionSteps,
    required this.image,
    required this.gifUrl,
    required this.attribution,
  });

  List<String> instructionsFor(String languageCode) {
    final localizedInstructions = instructionSteps[languageCode];

    if (localizedInstructions != null && localizedInstructions.isNotEmpty) {
      return localizedInstructions;
    }

    final englishInstructions = instructionSteps['en'];

    if (englishInstructions != null && englishInstructions.isNotEmpty) {
      return englishInstructions;
    }

    final spanishInstructions = instructionSteps['es'];

    if (spanishInstructions != null && spanishInstructions.isNotEmpty) {
      return spanishInstructions;
    }

    return const [];
  }

  Exercise toExercise() {
    return Exercise(
      id: id,
      name: name,
      target: target,
      equipment: equipment,
      image: image,
    );
  }

  factory ExerciseDetail.fromJson(Map<String, dynamic> json) {
    final rawSteps =
        json['instruction_steps'] as Map<String, dynamic>? ?? const {};

    final steps = rawSteps.map((language, value) {
      final items = value as List<dynamic>? ?? const [];

      return MapEntry(language, items.map((item) => item.toString()).toList());
    });

    return ExerciseDetail(
      id: json['id'] as String,
      name: json['name'] as String,
      target: json['target'] as String,
      equipment: json['equipment'] as String,
      muscleGroup: json['muscle_group'] as String? ?? '',
      secondaryMuscles:
          (json['secondary_muscles'] as List<dynamic>? ?? const [])
              .map((item) => item.toString())
              .toList(),
      instructionSteps: steps,
      image: json['image'] as String? ?? '',
      gifUrl: json['gif_url'] as String? ?? '',
      attribution: json['attribution'] as String? ?? '',
    );
  }
}
