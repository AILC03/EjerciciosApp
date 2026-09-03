import 'package:flutter/material.dart';

abstract final class AppColors {
  static const background = Color(0xFF09110F);
  static const appBar = Color(0xFF0D1B18);
  static const surface = Color(0xFF14211E);
  static const surfaceSecondary = Color(0xFF192925);

  static const primary = Color(0xFF2DD4BF);
  static const accent = Color(0xFFFBBF24);

  static const text = Color(0xFFEDF7F4);
  static const textSecondary = Color(0xFFA9BDB7);
  static const outline = Color(0xFF314640);
  static const error = Color(0xFFFFB4AB);
}

abstract final class AppTheme {
  static ThemeData get dark {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
          dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
        ).copyWith(
          primary: AppColors.primary,
          onPrimary: const Color(0xFF003731),
          secondary: AppColors.accent,
          onSecondary: const Color(0xFF3F2E00),
          surface: AppColors.surface,
          onSurface: AppColors.text,
          error: AppColors.error,
          outline: AppColors.outline,
        );

    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.appBar,
        foregroundColor: AppColors.text,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        elevation: 0,
      ),

      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withValues(alpha: 0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.outline),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: const Color(0xFF003731),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceSecondary,
        selectedColor: AppColors.primary,
        labelStyle: const TextStyle(color: AppColors.text),
        secondaryLabelStyle: const TextStyle(color: Color(0xFF003731)),
        side: const BorderSide(color: AppColors.outline),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
      ),

      dividerTheme: const DividerThemeData(color: AppColors.outline),

      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.primary,
        textColor: AppColors.text,
      ),

      iconTheme: const IconThemeData(color: AppColors.textSecondary),

      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.surfaceSecondary,
        contentTextStyle: TextStyle(color: AppColors.text),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
