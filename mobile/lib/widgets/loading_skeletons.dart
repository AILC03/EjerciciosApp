import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class MuscleGridSkeleton extends StatelessWidget {
  const MuscleGridSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 8,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.9,
        ),
        itemBuilder: (context, index) {
          return Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                Expanded(
                  child: Container(width: double.infinity, color: Colors.white),
                ),
                const Padding(
                  padding: EdgeInsets.all(14),
                  child: Text(
                    'Nombre del músculo',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ExerciseListSkeleton extends StatelessWidget {
  const ExerciseListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 6,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return Card(
            clipBehavior: Clip.antiAlias,
            child: SizedBox(
              height: 132,
              child: Row(
                children: [
                  Container(width: 132, height: 132, color: Colors.white),
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Nombre completo del ejercicio',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12),
                          Text('Equipo necesario'),
                          SizedBox(height: 8),
                          Text('Músculo principal'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class ExerciseDetailSkeleton extends StatelessWidget {
  const ExerciseDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            height: 300,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Nombre completo del ejercicio seleccionado',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(label: Text('Músculo principal')),
              Chip(label: Text('Equipo utilizado')),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Instrucciones',
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _InstructionSkeleton(number: 1),
          _InstructionSkeleton(number: 2),
          _InstructionSkeleton(number: 3),
          _InstructionSkeleton(number: 4),
        ],
      ),
    );
  }
}

class _InstructionSkeleton extends StatelessWidget {
  const _InstructionSkeleton({required this.number});

  final int number;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(child: Text('$number')),
      title: const Text(
        'Descripción del paso para realizar correctamente el ejercicio.',
      ),
    );
  }
}

/// Skeleton pequeño para imágenes o GIF individuales.
class MediaSkeleton extends StatelessWidget {
  const MediaSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: const Center(child: Icon(Icons.fitness_center, size: 52)),
      ),
    );
  }
}
