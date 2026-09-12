import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:ejercicios_app/services/api_exception.dart';
import 'package:ejercicios_app/services/auth_service.dart';

void main() {
  const userJson = <String, dynamic>{
    'id': '550e8400-e29b-41d4-a716-446655440000',
    'email': 'usuario@ejemplo.com',
    'is_active': true,
    'created_at': '2026-09-11T10:30:00Z',
  };

  http.Response jsonResponse(Map<String, dynamic> body, int statusCode) {
    return http.Response(
      jsonEncode(body),
      statusCode,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
  }

  group('AuthService', () {
    test('login envía las credenciales y devuelve el token', () async {
      final client = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.toString(), 'http://test/api/v1/auth/login');
        expect(request.headers['content-type'], 'application/json');

        final body = jsonDecode(request.body) as Map<String, dynamic>;

        expect(body['email'], 'usuario@ejemplo.com');
        expect(body['password'], 'Clave1234');

        return jsonResponse({
          'access_token': 'token-de-prueba',
          'token_type': 'bearer',
        }, 200);
      });

      final service = AuthService(client: client, baseUrl: 'http://test');
      addTearDown(service.dispose);

      final token = await service.login(
        email: ' usuario@ejemplo.com ',
        password: 'Clave1234',
      );

      expect(token.accessToken, 'token-de-prueba');
      expect(token.tokenType, 'bearer');
    });

    test('register envía los datos y devuelve el usuario creado', () async {
      final client = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.toString(), 'http://test/api/v1/auth/register');

        final body = jsonDecode(request.body) as Map<String, dynamic>;

        expect(body['email'], 'usuario@ejemplo.com');
        expect(body['password'], 'Clave1234');

        return jsonResponse(userJson, 201);
      });

      final service = AuthService(client: client, baseUrl: 'http://test');
      addTearDown(service.dispose);

      final user = await service.register(
        email: ' usuario@ejemplo.com ',
        password: 'Clave1234',
      );

      expect(user.id, userJson['id']);
      expect(user.email, 'usuario@ejemplo.com');
      expect(user.isActive, isTrue);
    });

    test('getCurrentUser envía el token y devuelve el usuario', () async {
      final client = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.toString(), 'http://test/api/v1/auth/me');
        expect(request.headers['authorization'], 'Bearer token-de-prueba');

        return jsonResponse(userJson, 200);
      });

      final service = AuthService(client: client, baseUrl: 'http://test');
      addTearDown(service.dispose);

      final user = await service.getCurrentUser('token-de-prueba');

      expect(user.id, userJson['id']);
      expect(user.email, 'usuario@ejemplo.com');
    });

    test('login convierte una respuesta 401 en ApiException', () async {
      final client = MockClient((request) async {
        return jsonResponse({'detail': 'Credenciales incorrectas'}, 401);
      });

      final service = AuthService(client: client, baseUrl: 'http://test');
      addTearDown(service.dispose);

      await expectLater(
        service.login(email: 'usuario@ejemplo.com', password: 'Incorrecta123'),
        throwsA(
          isA<ApiException>()
              .having((error) => error.statusCode, 'statusCode', 401)
              .having(
                (error) => error.message,
                'message',
                'Credenciales incorrectas',
              ),
        ),
      );
    });

    test('register informa cuando el correo ya existe', () async {
      final client = MockClient((request) async {
        return jsonResponse({'detail': 'El correo ya está registrado'}, 409);
      });

      final service = AuthService(client: client, baseUrl: 'http://test');
      addTearDown(service.dispose);

      await expectLater(
        service.register(email: 'usuario@ejemplo.com', password: 'Clave1234'),
        throwsA(
          isA<ApiException>()
              .having((error) => error.statusCode, 'statusCode', 409)
              .having(
                (error) => error.message,
                'message',
                'El correo ya está registrado',
              ),
        ),
      );
    });

    test('getCurrentUser informa cuando el token es rechazado', () async {
      final client = MockClient((request) async {
        return jsonResponse({'detail': 'Token inválido o vencido'}, 401);
      });

      final service = AuthService(client: client, baseUrl: 'http://test');
      addTearDown(service.dispose);

      await expectLater(
        service.getCurrentUser('token-vencido'),
        throwsA(
          isA<ApiException>().having(
            (error) => error.statusCode,
            'statusCode',
            401,
          ),
        ),
      );
    });
  });
}
