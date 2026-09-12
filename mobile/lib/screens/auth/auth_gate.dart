import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ejercicios_app/controllers/auth_controller.dart';
import 'package:ejercicios_app/l10n/locale_controller.dart';
import 'package:ejercicios_app/screens/auth/login_screen.dart';
import 'package:ejercicios_app/screens/auth/register_screen.dart';
import 'package:ejercicios_app/screens/muscle_selection_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key, required this.localeController});

  final LocaleController localeController;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _showRegister = false;

  void _openRegister() {
    setState(() {
      _showRegister = true;
    });
  }

  void _openLogin() {
    setState(() {
      _showRegister = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();

    if (!authController.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (authController.isAuthenticated) {
      return MuscleSelectionScreen(localeController: widget.localeController);
    }

    if (_showRegister) {
      return RegisterScreen(onLogin: _openLogin);
    }

    return LoginScreen(onRegister: _openRegister);
  }
}
