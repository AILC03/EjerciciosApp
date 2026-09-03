import 'dart:convert';

import '../models/exercise_detail.dart';

import 'package:http/http.dart' as http;

import '../models/exercise.dart';
import '../models/muscle.dart';

class ExerciseService {
  static const baseUrl = 'http://10.0.2.2:8000';

  Future<List<Muscle>> getMuscles() async {
    final uri = Uri.parse('$baseUrl/api/v1/muscles');
    final data = await _getJson(uri);

    final items = data['items'] as List<dynamic>;

    return items.map((item) => Muscle.fromApi(item as String)).toList();
  }

  Future<List<Exercise>> getExercises({required String muscle}) async {
    final uri = Uri.parse('$baseUrl/api/v1/exercises').replace(
      queryParameters: {'muscle': muscle, 'page': '1', 'page_size': '20'},
    );

    final data = await _getJson(uri);
    final items = data['items'] as List<dynamic>;

    return items
        .map((item) => Exercise.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<ExerciseDetail> getExerciseById(String exerciseId) async {
    final uri = Uri.parse('$baseUrl/api/v1/exercises/$exerciseId');

    final data = await _getJson(uri);

    return ExerciseDetail.fromJson(data);
  }

  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    final response = await http.get(uri).timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception(
        'El servidor respondió con código ${response.statusCode}',
      );
    }

    return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
  }
}
