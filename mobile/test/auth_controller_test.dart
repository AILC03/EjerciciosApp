import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:ejercicios_app/controllers/auth_controller.dart';
import 'package:ejercicios_app/services/auth_service.dart';
import 'package:ejercicios_app/services/token_storage.dart';

// Sustituye el almacenamiento del dispositivo durante las pruebas.
class MemoryTokenStorage extends TokenStorage {
  String? token;

  @override
  Future<void> saveToken(String value) async {
    token = value;
  }

  @override
  Future<String?> readToken() async => token;

  @override
  Future<void> deleteToken() async {
    token = null;
  }
}

void main() {
  const userJson = <String, dynamic>{
    'id': '550e8400-e29b-41d4-a716-446655440000',
    'email': 'usuario@ejemplo.com',
    'is_active': true,
    'created_at': '2026-09-11T10:30:00Z',
  };

  late MemoryTokenStorage storage;
  late AuthController controller;
  late List<String> requestedPaths;
  late bool rejectLogin;
  late bool rejectSession;

  http.Response jsonResponse(Map<String, dynamic> body, int statusCode) {
    return http.Response(
      jsonEncode(body),
      statusCode,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
  }

  setUp(() {
    storage = MemoryTokenStorage();
    requestedPaths = [];
    rejectLogin = false;
    rejectSession = false;

    final client = MockClient((request) async {
      requestedPaths.add(request.url.path);

      switch (request.url.path) {
        case '/api/v1/auth/register':
          return jsonResponse(userJson, 201);

        case '/api/v1/auth/login':
          if (rejectLogin) {
            return jsonResponse({'detail': 'Credenciales incorrectas'}, 401);
          }

          return jsonResponse({
            'access_token': 'token-de-prueba',
            'token_type': 'bearer',
          }, 200);

        case '/api/v1/auth/me':
          if (rejectSession) {
            return jsonResponse({'detail': 'Token vencido'}, 401);
          }

          return jsonResponse(userJson, 200);

        default:
          return jsonResponse({'detail': 'Ruta no encontrada'}, 404);
      }
    });

    controller = AuthController(
      authService: AuthService(client: client, baseUrl: 'http://test'),
      tokenStorage: storage,
    );
  });

  tearDown(() {
    controller.dispose();
  });

  test('sin token inicia sin sesión y no consulta el backend', () async {
    await controller.initialize();

    expect(controller.isInitialized, isTrue);
    expect(controller.isAuthenticated, isFalse);
    expect(controller.isLoading, isFalse);
    expect(requestedPaths, isEmpty);
  });

  test('recupera una sesión guardada', () async {
    storage.token = 'token-de-prueba';

    await controller.initialize();

    expect(controller.isAuthenticated, isTrue);
    expect(controller.user?.email, 'usuario@ejemplo.com');
    expect(storage.token, 'token-de-prueba');
    expect(requestedPaths, ['/api/v1/auth/me']);
  });

  test('elimina el token si el backend rechaza la sesión', () async {
    storage.token = 'token-vencido';
    rejectSession = true;

    await controller.initialize();

    expect(controller.isInitialized, isTrue);
    expect(controller.isAuthenticated, isFalse);
    expect(storage.token, isNull);
    expect(controller.isLoading, isFalse);
  });

  test('conserva el token cuando falla la conexión', () async {
    final offlineStorage = MemoryTokenStorage();
    offlineStorage.token = 'token-guardado';

    final offlineController = AuthController(
      authService: AuthService(
        client: MockClient((request) async {
          throw http.ClientException('Sin conexión');
        }),
        baseUrl: 'http://test',
      ),
      tokenStorage: offlineStorage,
    );

    addTearDown(offlineController.dispose);

    await offlineController.initialize();

    expect(offlineStorage.token, 'token-guardado');
    expect(offlineController.isAuthenticated, isFalse);
    expect(offlineController.isInitialized, isTrue);
    expect(offlineController.isLoading, isFalse);
    expect(offlineController.errorMessage, isNotNull);
  });

  test('login guarda el token y carga al usuario', () async {
    final result = await controller.login(
      email: 'usuario@ejemplo.com',
      password: 'Clave1234',
    );

    expect(result, isTrue);
    expect(storage.token, 'token-de-prueba');
    expect(controller.user?.email, 'usuario@ejemplo.com');
    expect(controller.isAuthenticated, isTrue);
    expect(controller.errorMessage, isNull);
    expect(controller.isLoading, isFalse);
    expect(requestedPaths, ['/api/v1/auth/login', '/api/v1/auth/me']);
  });

  test('login incorrecto muestra un error y no crea sesión', () async {
    rejectLogin = true;

    final result = await controller.login(
      email: 'usuario@ejemplo.com',
      password: 'Incorrecta123',
    );

    expect(result, isFalse);
    expect(controller.errorMessage, 'Credenciales incorrectas');
    expect(controller.isAuthenticated, isFalse);
    expect(storage.token, isNull);
    expect(controller.isLoading, isFalse);
    expect(requestedPaths, ['/api/v1/auth/login']);
  });

  test('registro inicia sesión automáticamente', () async {
    final result = await controller.register(
      email: 'usuario@ejemplo.com',
      password: 'Clave1234',
    );

    expect(result, isTrue);
    expect(controller.isAuthenticated, isTrue);
    expect(storage.token, 'token-de-prueba');
    expect(requestedPaths, [
      '/api/v1/auth/register',
      '/api/v1/auth/login',
      '/api/v1/auth/me',
    ]);
  });

  test('logout elimina el token y el usuario', () async {
    storage.token = 'token-de-prueba';
    await controller.initialize();

    expect(controller.isAuthenticated, isTrue);

    await controller.logout();

    expect(storage.token, isNull);
    expect(controller.user, isNull);
    expect(controller.isAuthenticated, isFalse);
    expect(controller.errorMessage, isNull);
  });
}
