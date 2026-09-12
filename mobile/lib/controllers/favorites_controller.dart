import 'dart:collection';

import 'package:flutter/foundation.dart';

import 'package:ejercicios_app/models/exercise.dart';
import 'package:ejercicios_app/services/api_exception.dart';
import 'package:ejercicios_app/services/favorite_service.dart';

class FavoritesController extends ChangeNotifier {
  FavoritesController({FavoriteService? favoriteService})
    : _favoriteService = favoriteService ?? FavoriteService();

  final FavoriteService _favoriteService;

  final List<Exercise> _favorites = [];
  final Set<String> _favoriteIds = {};
  final Set<String> _updatingIds = {};

  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;

  UnmodifiableListView<Exercise> get favorites {
    return UnmodifiableListView(_favorites);
  }

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool isFavorite(String exerciseId) {
    return _favoriteIds.contains(exerciseId);
  }

  bool isUpdating(String exerciseId) {
    return _updatingIds.contains(exerciseId);
  }

  void updateAuthentication(bool isAuthenticated) {
    if (_isAuthenticated == isAuthenticated) {
      return;
    }

    _isAuthenticated = isAuthenticated;

    if (isAuthenticated) {
      loadFavorites();
    } else {
      _clearFavorites();
    }
  }

  Future<void> loadFavorites() async {
    if (!_isAuthenticated || _isLoading) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final exercises = await _favoriteService.getFavorites();

      _favorites
        ..clear()
        ..addAll(exercises);

      _favoriteIds
        ..clear()
        ..addAll(exercises.map((exercise) => exercise.id));
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'No fue posible cargar los favoritos.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> toggleFavorite(Exercise exercise) async {
    if (!_isAuthenticated || _updatingIds.contains(exercise.id)) {
      return false;
    }

    _errorMessage = null;
    _updatingIds.add(exercise.id);
    notifyListeners();

    final wasFavorite = isFavorite(exercise.id);

    try {
      if (wasFavorite) {
        await _favoriteService.removeFavorite(exercise.id);

        _favoriteIds.remove(exercise.id);
        _favorites.removeWhere((favorite) => favorite.id == exercise.id);
      } else {
        await _favoriteService.addFavorite(exercise.id);

        _favoriteIds.add(exercise.id);

        if (!_favorites.any((favorite) => favorite.id == exercise.id)) {
          _favorites.insert(0, exercise);
        }
      }

      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'No fue posible actualizar el favorito.';
      return false;
    } finally {
      _updatingIds.remove(exercise.id);
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _clearFavorites() {
    _favorites.clear();
    _favoriteIds.clear();
    _updatingIds.clear();
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _favoriteService.dispose();
    super.dispose();
  }
}
