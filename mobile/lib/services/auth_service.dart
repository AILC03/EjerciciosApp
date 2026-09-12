import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:ejercicios_app/config/api_config.dart';
import 'package:ejercicios_app/models/auth_token.dart';
import 'package:ejercicios_app/models/user.dart';
import 'package:ejercicios_app/services/api_exception.dart';

class AuthService {
  AuthService({http.Client? client, this.baseUrl = ApiConfig.baseUrl})
    : _client = client ?? http.Client();

  final http.Client _client;
  final String baseUrl;

  Future<User> register({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/v1/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email.trim(), 'password': password}),
    );

    final body = _decodeBody(response);

    if (response.statusCode != 201) {
      throw ApiException(
        message: _extractError(body),
        statusCode: response.statusCode,
      );
    }

    return User.fromJson(body);
  }

  Future<AuthToken> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/v1/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email.trim(), 'password': password}),
    );

    final body = _decodeBody(response);

    if (response.statusCode != 200) {
      throw ApiException(
        message: _extractError(body),
        statusCode: response.statusCode,
      );
    }

    return AuthToken.fromJson(body);
  }

  Future<User> getCurrentUser(String token) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/v1/auth/me'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    final body = _decodeBody(response);

    if (response.statusCode != 200) {
      throw ApiException(
        message: _extractError(body),
        statusCode: response.statusCode,
      );
    }

    return User.fromJson(body);
  }

  Map<String, dynamic> _decodeBody(http.Response response) {
    if (response.body.isEmpty) {
      return {};
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw ApiException(
        message: 'El servidor devolvió una respuesta inesperada.',
        statusCode: response.statusCode,
      );
    }

    return decoded;
  }

  String _extractError(Map<String, dynamic> body) {
    final detail = body['detail'];

    if (detail is String) {
      return detail;
    }

    return 'No fue posible completar la solicitud.';
  }

  void dispose() {
    _client.close();
  }
}
