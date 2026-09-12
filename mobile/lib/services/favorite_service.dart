import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:ejercicios_app/config/api_config.dart';
import 'package:ejercicios_app/models/exercise.dart';
import 'package:ejercicios_app/services/api_exception.dart';
import 'package:ejercicios_app/services/token_storage.dart';

class FavoriteService {
  FavoriteService({
    http.Client? client,
    TokenStorage? tokenStorage,
    this.baseUrl = ApiConfig.baseUrl,
  }) : _client = client ?? http.Client(),
       _tokenStorage = tokenStorage ?? TokenStorage();

  final http.Client _client;
  final TokenStorage _tokenStorage;
  final String baseUrl;

  Future<List<Exercise>> getFavorites() async {
    final token = await _requireToken();

    final response = await _client
        .get(
          Uri.parse('$baseUrl/api/v1/favorites'),
          headers: _authorizationHeaders(token),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw _createApiException(response);
    }

    final data = _decodeBody(response);
    final items = data['items'] as List<dynamic>? ?? [];

    return items
        .map((item) => Exercise.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> addFavorite(String exerciseId) async {
    final token = await _requireToken();

    final response = await _client
        .post(
          Uri.parse(
            '$baseUrl/api/v1/favorites/'
            '${Uri.encodeComponent(exerciseId)}',
          ),
          headers: _authorizationHeaders(token),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 201) {
      throw _createApiException(response);
    }
  }

  Future<void> removeFavorite(String exerciseId) async {
    final token = await _requireToken();

    final response = await _client
        .delete(
          Uri.parse(
            '$baseUrl/api/v1/favorites/'
            '${Uri.encodeComponent(exerciseId)}',
          ),
          headers: _authorizationHeaders(token),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 204) {
      throw _createApiException(response);
    }
  }

  Future<String> _requireToken() async {
    final token = await _tokenStorage.readToken();

    if (token == null || token.isEmpty) {
      throw const ApiException(
        message: 'Debes iniciar sesión',
        statusCode: 401,
      );
    }

    return token;
  }

  Map<String, String> _authorizationHeaders(String token) {
    return {'Authorization': 'Bearer $token', 'Accept': 'application/json'};
  }

  Map<String, dynamic> _decodeBody(http.Response response) {
    final decoded = jsonDecode(utf8.decode(response.bodyBytes));

    if (decoded is! Map<String, dynamic>) {
      throw ApiException(
        message: 'El servidor devolvió una respuesta inesperada.',
        statusCode: response.statusCode,
      );
    }

    return decoded;
  }

  ApiException _createApiException(http.Response response) {
    var message = 'No fue posible completar la solicitud.';

    if (response.bodyBytes.isNotEmpty) {
      try {
        final body = _decodeBody(response);
        final detail = body['detail'];

        if (detail is String && detail.isNotEmpty) {
          message = detail;
        }
      } on FormatException {
        // Se conserva el mensaje general.
      }
    }

    return ApiException(message: message, statusCode: response.statusCode);
  }

  void dispose() {
    _client.close();
  }
}
