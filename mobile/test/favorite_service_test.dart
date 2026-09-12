import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:ejercicios_app/services/api_exception.dart';
import 'package:ejercicios_app/services/favorite_service.dart';
import 'package:ejercicios_app/services/token_storage.dart';

class MemoryTokenStorage extends TokenStorage {
  MemoryTokenStorage(this.token);

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
  const baseUrl = 'http://test';
  const token = 'token-de-prueba';

  http.Response jsonResponse(Map<String, dynamic> body, int statusCode) {
    return http.Response(
      jsonEncode(body),
      statusCode,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
  }

  test('getFavorites envía el token y convierte los ejercicios', () async {
    final client = MockClient((request) async {
      expect(request.method, 'GET');
      expect(request.url.toString(), '$baseUrl/api/v1/favorites');
      expect(request.headers['authorization'], 'Bearer $token');

      return jsonResponse({
        'total': 1,
        'items': [
          {
            'id': '0001',
            'name': 'Exercise',
            'target': 'abs',
            'equipment': 'body weight',
            'image': 'https://example.com/exercise.jpg',
          },
        ],
      }, 200);
    });

    final service = FavoriteService(
      client: client,
      tokenStorage: MemoryTokenStorage(token),
      baseUrl: baseUrl,
    );

    addTearDown(service.dispose);

    final favorites = await service.getFavorites();

    expect(favorites, hasLength(1));
    expect(favorites.first.id, '0001');
    expect(favorites.first.name, 'Exercise');
  });

  test('addFavorite envía POST con el identificador', () async {
    final client = MockClient((request) async {
      expect(request.method, 'POST');
      expect(request.url.toString(), '$baseUrl/api/v1/favorites/0001');
      expect(request.headers['authorization'], 'Bearer $token');

      return http.Response('', 201);
    });

    final service = FavoriteService(
      client: client,
      tokenStorage: MemoryTokenStorage(token),
      baseUrl: baseUrl,
    );

    addTearDown(service.dispose);

    await service.addFavorite('0001');
  });

  test('removeFavorite envía DELETE con el identificador', () async {
    final client = MockClient((request) async {
      expect(request.method, 'DELETE');
      expect(request.url.toString(), '$baseUrl/api/v1/favorites/0001');
      expect(request.headers['authorization'], 'Bearer $token');

      return http.Response('', 204);
    });

    final service = FavoriteService(
      client: client,
      tokenStorage: MemoryTokenStorage(token),
      baseUrl: baseUrl,
    );

    addTearDown(service.dispose);

    await service.removeFavorite('0001');
  });

  test('no hace peticiones cuando no existe un token', () async {
    var requestWasSent = false;

    final client = MockClient((request) async {
      requestWasSent = true;
      return http.Response('', 500);
    });

    final service = FavoriteService(
      client: client,
      tokenStorage: MemoryTokenStorage(null),
      baseUrl: baseUrl,
    );

    addTearDown(service.dispose);

    await expectLater(
      service.getFavorites(),
      throwsA(
        isA<ApiException>().having(
          (error) => error.statusCode,
          'statusCode',
          401,
        ),
      ),
    );

    expect(requestWasSent, isFalse);
  });

  test('convierte un error del backend en ApiException', () async {
    final client = MockClient((request) async {
      return jsonResponse({'detail': 'El ejercicio ya está en favoritos'}, 409);
    });

    final service = FavoriteService(
      client: client,
      tokenStorage: MemoryTokenStorage(token),
      baseUrl: baseUrl,
    );

    addTearDown(service.dispose);

    await expectLater(
      service.addFavorite('0001'),
      throwsA(
        isA<ApiException>()
            .having((error) => error.statusCode, 'statusCode', 409)
            .having(
              (error) => error.message,
              'message',
              'El ejercicio ya está en favoritos',
            ),
      ),
    );
  });
}
