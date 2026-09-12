import 'package:flutter_test/flutter_test.dart';

import 'package:ejercicios_app/models/auth_token.dart';
import 'package:ejercicios_app/models/user.dart';

void main() {
  group('User.fromJson', () {
    test('convierte correctamente el JSON del backend', () {
      final json = <String, dynamic>{
        'id': '550e8400-e29b-41d4-a716-446655440000',
        'email': 'usuario@ejemplo.com',
        'is_active': true,
        'created_at': '2026-09-11T10:30:00Z',
      };

      final user = User.fromJson(json);

      expect(user.id, '550e8400-e29b-41d4-a716-446655440000');
      expect(user.email, 'usuario@ejemplo.com');
      expect(user.isActive, isTrue);
      expect(user.createdAt, DateTime.utc(2026, 9, 11, 10, 30));
    });
  });

  group('AuthToken.fromJson', () {
    test('convierte correctamente el token del backend', () {
      final json = <String, dynamic>{
        'access_token': 'token-de-prueba',
        'token_type': 'bearer',
      };

      final authToken = AuthToken.fromJson(json);

      expect(authToken.accessToken, 'token-de-prueba');
      expect(authToken.tokenType, 'bearer');
    });
  });
}
