import 'package:flutter_test/flutter_test.dart';

import 'package:ejercicios_app/controllers/favorites_controller.dart';
import 'package:ejercicios_app/models/exercise.dart';
import 'package:ejercicios_app/services/favorite_service.dart';

class FakeFavoriteService extends FavoriteService {
  FakeFavoriteService([List<Exercise> initialFavorites = const []])
    : storedFavorites = List.of(initialFavorites);

  final List<Exercise> storedFavorites;
  int addCalls = 0;
  int removeCalls = 0;

  @override
  Future<List<Exercise>> getFavorites() async {
    return List.of(storedFavorites);
  }

  @override
  Future<void> addFavorite(String exerciseId) async {
    addCalls += 1;
  }

  @override
  Future<void> removeFavorite(String exerciseId) async {
    removeCalls += 1;
  }
}

const exercise = Exercise(
  id: '0001',
  name: 'Exercise',
  target: 'abs',
  equipment: 'body weight',
  image: 'https://example.com/exercise.jpg',
);

Future<void> waitForLoading(FavoritesController controller) async {
  while (controller.isLoading) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  test('loads favorites after authentication', () async {
    final service = FakeFavoriteService([exercise]);
    final controller = FavoritesController(favoriteService: service);
    addTearDown(controller.dispose);

    controller.updateAuthentication(true);
    await waitForLoading(controller);

    expect(controller.isAuthenticated, isTrue);
    expect(controller.favorites, hasLength(1));
    expect(controller.isFavorite('0001'), isTrue);
  });

  test('a guest cannot change favorites', () async {
    final service = FakeFavoriteService();
    final controller = FavoritesController(favoriteService: service);
    addTearDown(controller.dispose);

    final result = await controller.toggleFavorite(exercise);

    expect(result, isFalse);
    expect(service.addCalls, 0);
    expect(controller.favorites, isEmpty);
  });

  test('adds and removes a favorite', () async {
    final service = FakeFavoriteService();
    final controller = FavoritesController(favoriteService: service);
    addTearDown(controller.dispose);

    controller.updateAuthentication(true);
    await waitForLoading(controller);

    expect(await controller.toggleFavorite(exercise), isTrue);
    expect(service.addCalls, 1);
    expect(controller.isFavorite('0001'), isTrue);

    expect(await controller.toggleFavorite(exercise), isTrue);
    expect(service.removeCalls, 1);
    expect(controller.isFavorite('0001'), isFalse);
  });

  test('clears favorites after logout', () async {
    final controller = FavoritesController(
      favoriteService: FakeFavoriteService([exercise]),
    );
    addTearDown(controller.dispose);

    controller.updateAuthentication(true);
    await waitForLoading(controller);
    controller.updateAuthentication(false);

    expect(controller.isAuthenticated, isFalse);
    expect(controller.favorites, isEmpty);
    expect(controller.isFavorite('0001'), isFalse);
  });
}
