import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'favorites_screen.dart';
import 'auth/auth_flow_screen.dart';
import '../controllers/auth_controller.dart';
import '../l10n/app_localizations.dart';
import '../l10n/locale_controller.dart';
import '../models/muscle.dart';
import '../services/exercise_service.dart';
import '../widgets/loading_skeletons.dart';
import 'exercise_screen.dart';

class MuscleSelectionScreen extends StatefulWidget {
  const MuscleSelectionScreen({super.key, required this.localeController});

  final LocaleController localeController;

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

  Future<void> _openAuthentication() async {
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const AuthFlowScreen()));
  }

  void _openFavorites() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const FavoritesScreen()));
  }

  Future<void> _logout() async {
    final texts = AppLocalizations.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(texts.logout),
          content: Text(texts.logoutConfirmation),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: Text(texts.cancel),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: Text(texts.logout),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    await context.read<AuthController>().logout();
  }

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);
    final authController = context.watch<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(texts.appName),
        actions: [
          PopupMenuButton<String>(
            initialValue: widget.localeController.selectedLanguageCode,
            tooltip: texts.language,
            icon: const Icon(Icons.language),
            onSelected: (languageCode) async {
              await widget.localeController.changeLanguage(languageCode);
            },
            itemBuilder: (context) {
              final selectedLanguage =
                  widget.localeController.selectedLanguageCode;

              return [
                CheckedPopupMenuItem<String>(
                  value: 'system',
                  checked: selectedLanguage == 'system',
                  child: Text(texts.systemLanguage),
                ),
                CheckedPopupMenuItem<String>(
                  value: 'es',
                  checked: selectedLanguage == 'es',
                  child: Text(texts.spanish),
                ),
                CheckedPopupMenuItem<String>(
                  value: 'en',
                  checked: selectedLanguage == 'en',
                  child: Text(texts.english),
                ),
              ];
            },
          ),
          if (authController.isAuthenticated) ...[
            IconButton(
              onPressed: _openFavorites,
              tooltip: texts.favoritesTitle,
              icon: const Icon(Icons.favorite_outline),
            ),
            IconButton(
              onPressed: _logout,
              tooltip: texts.logout,
              icon: const Icon(Icons.logout),
            ),
          ] else
            IconButton(
              onPressed: _openAuthentication,
              tooltip: texts.login,
              icon: const Icon(Icons.account_circle_outlined),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: FutureBuilder<List<Muscle>>(
        future: _muscles,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const MuscleGridSkeleton();
          }

          if (snapshot.hasError) {
            return _ErrorContent(onRetry: _reload);
          }

          final muscles = snapshot.data ?? [];

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        texts.chooseWorkout,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        texts.chooseMuscleGroup,
                        style: const TextStyle(fontSize: 16),
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
                                    cacheWidth: 400,
                                    cacheHeight: 400,
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
                                muscle.localizedLabel(texts),
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
  const _ErrorContent({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 48),
            const SizedBox(height: 12),
            Text(texts.musclesLoadError, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: Text(texts.retry)),
          ],
        ),
      ),
    );
  }
}
