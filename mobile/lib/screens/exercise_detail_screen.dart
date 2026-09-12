import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/favorites_controller.dart';
import '../l10n/exercise_labels.dart';
import '../l10n/app_localizations.dart';
import '../models/exercise_detail.dart';
import '../services/exercise_service.dart';
import '../widgets/loading_skeletons.dart';
import 'auth/auth_flow_screen.dart';

class ExerciseDetailScreen extends StatefulWidget {
  final String exerciseId;

  const ExerciseDetailScreen({super.key, required this.exerciseId});

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  final ExerciseService _service = ExerciseService();

  late Future<ExerciseDetail> _exercise;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _exercise = _service.getExerciseById(widget.exerciseId);
  }

  void _reload() {
    setState(_load);
  }

  Future<void> _handleFavorite(ExerciseDetail exercise) async {
    final favoritesController = context.read<FavoritesController>();

    if (!favoritesController.isAuthenticated) {
      await Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => const AuthFlowScreen()));
      return;
    }

    final success = await favoritesController.toggleFavorite(
      exercise.toExercise(),
    );

    if (!mounted || success) {
      return;
    }

    final message = favoritesController.errorMessage;

    if (message != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);
    final favoritesController = context.watch<FavoritesController>();

    return Scaffold(
      appBar: AppBar(title: Text(texts.exerciseDetail)),
      body: FutureBuilder<ExerciseDetail>(
        future: _exercise,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const ExerciseDetailSkeleton();
          }

          if (snapshot.hasError) {
            return _ErrorContent(onRetry: _reload);
          }

          final exercise = snapshot.data!;

          return _DetailContent(
            exercise: exercise,
            isFavorite: favoritesController.isFavorite(exercise.id),
            isFavoriteLoading: favoritesController.isUpdating(exercise.id),
            onFavoritePressed: () => _handleFavorite(exercise),
          );
        },
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  final ExerciseDetail exercise;
  final bool isFavorite;
  final bool isFavoriteLoading;
  final VoidCallback onFavoritePressed;

  const _DetailContent({
    required this.exercise,
    required this.isFavorite,
    required this.isFavoriteLoading,
    required this.onFavoritePressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final texts = AppLocalizations.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;
    final instructions = exercise.instructionsFor(languageCode);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                exercise.name,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: isFavoriteLoading ? null : onFavoritePressed,
              tooltip: isFavorite ? texts.removeFavorite : texts.addFavorite,
              icon: isFavoriteLoading
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _ExerciseGif(url: exercise.gifUrl),
        const SizedBox(height: 20),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Chip(
              avatar: const Icon(Icons.fitness_center, size: 18),
              label: Text(texts.equipmentLabel(exercise.equipment)),
            ),
            Chip(
              avatar: const Icon(Icons.accessibility_new, size: 18),
              label: Text(texts.muscleLabel(exercise.target)),
            ),
          ],
        ),
        if (exercise.secondaryMuscles.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(
            texts.secondaryMuscles,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(exercise.secondaryMuscles.map(texts.muscleLabel).join(', ')),
        ],
        const SizedBox(height: 24),
        Text(
          texts.instructions,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (instructions.isEmpty)
          Text(texts.noInstructions)
        else
          ...List.generate(instructions.length, (index) {
            return _InstructionStep(
              number: index + 1,
              text: instructions[index],
            );
          }),
        if (exercise.attribution.isNotEmpty) ...[
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 8),
          Text(
            exercise.attribution,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

class _ExerciseGif extends StatelessWidget {
  final String url;

  const _ExerciseGif({required this.url});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AspectRatio(
      aspectRatio: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: ColoredBox(
          color: colorScheme.surfaceContainerLow,
          child: url.isEmpty
              ? const _GifFallback()
              : CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.contain,
                  placeholder: (context, url) {
                    return const MediaSkeleton();
                  },
                  errorWidget: (context, url, error) {
                    return const _GifFallback();
                  },
                ),
        ),
      ),
    );
  }
}

class _GifFallback extends StatelessWidget {
  const _GifFallback();

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.broken_image_outlined, size: 48),
          const SizedBox(height: 8),
          Text(texts.gifUnavailable),
        ],
      ),
    );
  }
}

class _InstructionStep extends StatelessWidget {
  final int number;
  final String text;

  const _InstructionStep({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 15,
            backgroundColor: colorScheme.primaryContainer,
            foregroundColor: colorScheme.onPrimaryContainer,
            child: Text(
              '$number',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(text),
            ),
          ),
        ],
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
            Text(texts.exerciseLoadError, textAlign: TextAlign.center),
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
