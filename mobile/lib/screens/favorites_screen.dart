import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/favorites_controller.dart';
import '../l10n/app_localizations.dart';
import '../models/exercise.dart';
import '../models/muscle.dart';
import '../widgets/exercise_card.dart';
import '../widgets/loading_skeletons.dart';
import 'exercise_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  Map<String, List<Exercise>> _groupByMuscle(Iterable<Exercise> favorites) {
    final groups = <String, List<Exercise>>{};

    for (final exercise in favorites) {
      final muscle = exercise.target.trim().toLowerCase();

      groups.putIfAbsent(muscle, () => []).add(exercise);
    }

    return groups;
  }

  Future<void> _toggleFavorite(BuildContext context, Exercise exercise) async {
    final controller = context.read<FavoritesController>();
    final success = await controller.toggleFavorite(exercise);

    if (!context.mounted || success) {
      return;
    }

    final message = controller.errorMessage;

    if (message != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);
    final controller = context.watch<FavoritesController>();
    final favorites = controller.favorites;
    final groupedFavorites = _groupByMuscle(favorites);
    final muscleGroups = groupedFavorites.entries.toList()
      ..sort((first, second) {
        final firstName = Muscle(apiValue: first.key).localizedLabel(texts);
        final secondName = Muscle(apiValue: second.key).localizedLabel(texts);

        return firstName.compareTo(secondName);
      });

    Widget body;

    if (controller.isLoading && favorites.isEmpty) {
      body = const ExerciseListSkeleton();
    } else if (controller.errorMessage != null && favorites.isEmpty) {
      body = Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 52),
              const SizedBox(height: 16),
              Text(texts.favoritesLoadError, textAlign: TextAlign.center),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: controller.loadFavorites,
                icon: const Icon(Icons.refresh),
                label: Text(texts.retry),
              ),
            ],
          ),
        ),
      );
    } else if (favorites.isEmpty) {
      body = Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.favorite_border,
                size: 52,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                texts.noFavorites,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(texts.noFavoritesDescription, textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    } else {
      body = RefreshIndicator(
        onRefresh: controller.loadFavorites,
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemCount: muscleGroups.length,
          separatorBuilder: (context, index) {
            return const SizedBox(height: 10);
          },
          itemBuilder: (context, index) {
            final group = muscleGroups[index];
            final muscleValue = group.key;
            final exercises = group.value;
            final muscleName = Muscle(apiValue: muscleValue)
                .localizedLabel(texts);

            return Card(
              clipBehavior: Clip.antiAlias,
              child: ExpansionTile(
                key: PageStorageKey('favorite-muscle-$muscleValue'),
                leading: const Icon(Icons.fitness_center),
                title: Text(
                  muscleName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(texts.favoriteExerciseCount(exercises.length)),
                maintainState: true,
                childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                children: [
                  for (final exercise in exercises)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: ExerciseCard(
                        exercise: exercise,
                        isFavorite: true,
                        isFavoriteLoading: controller.isUpdating(exercise.id),
                        onFavoritePressed: () {
                          _toggleFavorite(context, exercise);
                        },
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  ExerciseDetailScreen(exerciseId: exercise.id),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(texts.favoritesTitle)),
      body: body,
    );
  }
}
