import 'package:flutter/material.dart';

import 'login_screen.dart';
import 'register_screen.dart';

class AuthFlowScreen extends StatefulWidget {
  const AuthFlowScreen({super.key});

  @override
  State<AuthFlowScreen> createState() => _AuthFlowScreenState();
}

class _AuthFlowScreenState extends State<AuthFlowScreen> {
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

  void _finishAuthentication() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (_showRegister) {
      return RegisterScreen(
        onLogin: _openLogin,
        onAuthenticated: _finishAuthentication,
      );
    }

    return LoginScreen(
      onRegister: _openRegister,
      onAuthenticated: _finishAuthentication,
    );
  }
}
