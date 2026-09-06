import 'package:flutter_test/flutter_test.dart';
import 'package:ejercicios_app/models/exercise_detail.dart';
import 'package:ejercicios_app/models/exercise.dart';

void main() {
  test('Convierte el detalle y elige instrucciones en español', () {
    final detail = ExerciseDetail.fromJson({
      'id': '0001',
      'name': 'Ejercicio de prueba',
      'target': 'abs',
      'equipment': 'body weight',
      'muscle_group': 'core',
      'secondary_muscles': ['lower back'],
      'instruction_steps': {
        'en': ['English instruction'],
        'es': ['Instrucción en español'],
      },
      'gif_url': 'https://example.com/exercise.gif',
      'attribution': 'Fuente de prueba',
    });

    expect(detail.id, '0001');
    expect(detail.instructionsFor('es'), ['Instrucción en español']);

    expect(detail.instructionsFor('en'), ['English instruction']);
    expect(detail.instructionsFor('fr'), ['English instruction']);
    expect(detail.secondaryMuscles, ['lower back']);
    expect(detail.gifUrl, 'https://example.com/exercise.gif');
  });

  test('usa español como respaldo si no existen instrucciones en inglés', () {
    final detail = ExerciseDetail.fromJson({
      'id': '0003',
      'name': 'Ejercicio de prueba',
      'target': 'abs',
      'equipment': 'body weight',
      'instruction_steps': {
        'es': ['Única instrucción disponible'],
      },
    });

    expect(detail.instructionsFor('en'), ['Única instrucción disponible']);
  });
  test('Convierte un ejercicio JSON y conserva sus datos', () {
    final exercise = Exercise.fromJson({
      'id': '0001',
      'name': 'Ejercicio de prueba',
      'target': 'abs',
      'equipment': 'body weight',
      'image': 'https://example.com/exercise.jpg',
    });

    expect(exercise.id, '0001');
    expect(exercise.name, 'Ejercicio de prueba');
    expect(exercise.target, 'abs');
    expect(exercise.equipment, 'body weight');
    expect(exercise.image, 'https://example.com/exercise.jpg');
  });

  test('Usa texto vacío cuando un ejercicio no tiene imagen', () {
    final exercise = Exercise.fromJson({
      'id': '0002',
      'name': 'Ejercicio sin imagen',
      'target': 'biceps',
      'equipment': 'dumbbell',
    });

    expect(exercise.image, '');
  });
}
