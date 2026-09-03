import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/exercise_detail.dart';
import '../services/exercise_service.dart';
import '../widgets/loading_skeletons.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del ejercicio')),
      body: FutureBuilder<ExerciseDetail>(
        future: _exercise,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const ExerciseDetailSkeleton();
          }

          if (snapshot.hasError) {
            return _ErrorContent(error: snapshot.error, onRetry: _reload);
          }

          final exercise = snapshot.data!;

          return _DetailContent(exercise: exercise);
        },
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  final ExerciseDetail exercise;

  const _DetailContent({required this.exercise});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        Text(
          exercise.name,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
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
              label: Text(exercise.equipment),
            ),
            Chip(
              avatar: const Icon(Icons.accessibility_new, size: 18),
              label: Text(exercise.target),
            ),
          ],
        ),
        if (exercise.secondaryMuscles.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(
            'Músculos secundarios',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(exercise.secondaryMuscles.join(', ')),
        ],
        const SizedBox(height: 24),
        Text(
          'Instrucciones',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (exercise.instructions.isEmpty)
          const Text('No hay instrucciones disponibles.')
        else
          ...List.generate(exercise.instructions.length, (index) {
            return _InstructionStep(
              number: index + 1,
              text: exercise.instructions[index],
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
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.broken_image_outlined, size: 48),
          SizedBox(height: 8),
          Text('GIF no disponible'),
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
  final Object? error;
  final VoidCallback onRetry;

  const _ErrorContent({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
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
            const Text(
              'No pudimos cargar el ejercicio.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text('$error', textAlign: TextAlign.center),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
