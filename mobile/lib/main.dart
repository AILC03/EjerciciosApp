import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'controllers/auth_controller.dart';
import 'l10n/app_localizations.dart';
import 'l10n/locale_controller.dart';
import 'screens/auth/auth_gate.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final localeController = LocaleController();
  await localeController.load();

  runApp(EjerciciosApp(localeController: localeController));
}

class EjerciciosApp extends StatelessWidget {
  const EjerciciosApp({super.key, required this.localeController});

  final LocaleController localeController;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthController()..initialize(),
      child: ListenableBuilder(
        listenable: localeController,
        builder: (context, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            onGenerateTitle: (context) {
              return AppLocalizations.of(context).appName;
            },
            theme: AppTheme.dark,
            locale: localeController.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: AuthGate(localeController: localeController),
          );
        },
      ),
    );
  }
}
