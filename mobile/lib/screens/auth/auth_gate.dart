import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ejercicios_app/controllers/auth_controller.dart';
import 'package:ejercicios_app/l10n/locale_controller.dart';
import 'package:ejercicios_app/screens/muscle_selection_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key, required this.localeController});

  final LocaleController localeController;

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();

    if (!authController.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return MuscleSelectionScreen(localeController: localeController);
  }
}
