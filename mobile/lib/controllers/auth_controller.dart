import 'package:flutter/foundation.dart';

import 'package:ejercicios_app/models/user.dart';
import 'package:ejercicios_app/services/api_exception.dart';
import 'package:ejercicios_app/services/auth_service.dart';
import 'package:ejercicios_app/services/token_storage.dart';

class AuthController extends ChangeNotifier {
  AuthController({AuthService? authService, TokenStorage? tokenStorage})
    : _authService = authService ?? AuthService(),
      _tokenStorage = tokenStorage ?? TokenStorage();

  final AuthService _authService;
  final TokenStorage _tokenStorage;

  User? _user;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  Future<void> initialize() async {
    if (_isInitialized || _isLoading) {
      return;
    }

    _errorMessage = null;
    _setLoading(true);

    try {
      final token = await _tokenStorage.readToken();

      if (token != null && token.isNotEmpty) {
        _user = await _authService.getCurrentUser(token);
      }
    } on ApiException catch (error) {
      _user = null;

      if (error.statusCode == 401 || error.statusCode == 403) {
        await _tokenStorage.deleteToken();
      } else {
        _errorMessage = 'No fue posible comprobar la sesión.';
      }
    } catch (_) {
      _user = null;
      _errorMessage = 'No fue posible comprobar la sesión.';
    } finally {
      _isInitialized = true;
      _setLoading(false);
    }
  }

  Future<bool> register({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _authService.register(email: email, password: password);

      return await login(email: email, password: password);
    } on ApiException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'No fue posible crear la cuenta.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> login({required String email, required String password}) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final authToken = await _authService.login(
        email: email,
        password: password,
      );

      await _tokenStorage.saveToken(authToken.accessToken);

      _user = await _authService.getCurrentUser(authToken.accessToken);

      notifyListeners();
      return true;
    } on ApiException catch (error) {
      await _tokenStorage.deleteToken();
      _user = null;
      _errorMessage = error.message;
      return false;
    } catch (_) {
      await _tokenStorage.deleteToken();
      _user = null;
      _errorMessage = 'No fue posible iniciar sesión.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await _tokenStorage.deleteToken();

    _user = null;
    _errorMessage = null;

    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _authService.dispose();
    super.dispose();
  }
}
