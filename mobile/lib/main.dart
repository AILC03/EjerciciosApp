import 'package:flutter/material.dart';

import 'theme/app_theme.dart';
import 'screens/muscle_selection_screen.dart';

void main() {
  runApp(const EjerciciosApp());
}

class EjerciciosApp extends StatelessWidget {
  const EjerciciosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EjerciciosApp',
      theme: AppTheme.dark,
      home: const MuscleSelectionScreen(),
    );
  }
}
