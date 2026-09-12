import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/favorites_controller.dart';
import 'auth/auth_flow_screen.dart';
import '../l10n/app_localizations.dart';
import '../models/exercise.dart';
import '../models/muscle.dart';
import '../services/exercise_service.dart';
import '../widgets/exercise_card.dart';
import '../widgets/loading_skeletons.dart';
import 'exercise_detail_screen.dart';

class ExercisesScreen extends StatefulWidget {
  final Muscle muscle;

  const ExercisesScreen({super.key, required this.muscle});

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  final ExerciseService _service = ExerciseService();

  late Future<List<Exercise>> _exercises;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _exercises = _service.getExercises(muscle: widget.muscle.apiValue);
  }

  void _reload() {
    setState(_load);
  }

  Future<void> _handleFavorite(Exercise exercise) async {
    final favoritesController = context.read<FavoritesController>();

    if (!favoritesController.isAuthenticated) {
      await Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => const AuthFlowScreen()));

      return;
    }

    final success = await favoritesController.toggleFavorite(exercise);

    if (!mounted || success) {
      return;
    }

    final errorMessage = context.read<FavoritesController>().errorMessage;

    if (errorMessage != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);
    final favoritesController = context.watch<FavoritesController>();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.muscle.localizedLabel(texts)),
        actions: [
          IconButton(
            onPressed: _reload,
            icon: const Icon(Icons.refresh),
            tooltip: texts.refresh,
          ),
        ],
      ),
      body: FutureBuilder<List<Exercise>>(
        future: _exercises,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const ExerciseListSkeleton();
          }

          if (snapshot.hasError) {
            return _ErrorContent(onRetry: _reload);
          }

          final exercises = snapshot.data ?? [];

          if (exercises.isEmpty) {
            return const _EmptyContent();
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: exercises.length,
            separatorBuilder: (context, index) {
              return const SizedBox(height: 12);
            },
            itemBuilder: (context, index) {
              final exercise = exercises[index];

              return ExerciseCard(
                exercise: exercise,
                isFavorite: favoritesController.isFavorite(exercise.id),
                isFavoriteLoading: favoritesController.isUpdating(exercise.id),
                onFavoritePressed: () {
                  _handleFavorite(exercise);
                },
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          ExerciseDetailScreen(exerciseId: exercise.id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _ErrorContent extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorContent({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off,
              size: 52,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              texts.exercisesLoadError,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(texts.retry),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyContent extends StatelessWidget {
  const _EmptyContent();

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off,
              size: 52,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              texts.noExercises,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(texts.selectAnotherMuscle, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
