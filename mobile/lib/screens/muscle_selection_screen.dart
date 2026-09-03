import 'package:flutter/material.dart';

import '../models/muscle.dart';
import '../services/exercise_service.dart';
import '../widgets/loading_skeletons.dart';
import 'exercise_screen.dart';

class MuscleSelectionScreen extends StatefulWidget {
  const MuscleSelectionScreen({super.key});

  @override
  State<MuscleSelectionScreen> createState() => _MuscleSelectionScreenState();
}

class _MuscleSelectionScreenState extends State<MuscleSelectionScreen> {
  final ExerciseService _service = ExerciseService();

  late Future<List<Muscle>> _muscles;

  @override
  void initState() {
    super.initState();
    _muscles = _service.getMuscles();
  }

  void _reload() {
    setState(() {
      _muscles = _service.getMuscles();
    });
  }

  void _openMuscle(Muscle muscle) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => ExercisesScreen(muscle: muscle)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('EjerciciosApp')),
      body: FutureBuilder<List<Muscle>>(
        future: _muscles,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const MuscleGridSkeleton();
          }

          if (snapshot.hasError) {
            return _ErrorContent(error: snapshot.error, onRetry: _reload);
          }

          final muscles = snapshot.data ?? [];

          return CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¿Qué quieres entrenar?',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Elige un grupo muscular',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: muscles.length,
                  itemBuilder: (context, index) {
                    final muscle = muscles[index];

                    return Card(
                      clipBehavior: Clip.antiAlias,
                      margin: EdgeInsets.zero,
                      child: InkWell(
                        onTap: () => _openMuscle(muscle),
                        child: Column(
                          children: [
                            Expanded(
                              child: ColoredBox(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerLow,
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Image.asset(
                                    muscle.imagePath,
                                    width: double.infinity,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Center(
                                        child: Icon(
                                          Icons.fitness_center,
                                          size: 48,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Text(
                                muscle.label,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
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
            const Icon(Icons.cloud_off, size: 48),
            const SizedBox(height: 12),
            const Text('No pudimos cargar los músculos.'),
            const SizedBox(height: 8),
            Text('$error', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }
}
