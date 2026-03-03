import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_widgets_guardiapp/theme/app_theme.dart';
import 'package:flutter_widgets_guardiapp/layout/main_layout.dart';
import 'package:flutter_widgets_guardiapp/models/app_state.dart';

import 'package:flutter_widgets_guardiapp/screens/auth/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return MaterialApp(
          title: 'Guardiapp',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: ThemeData.dark(useMaterial3: true),
          themeMode: appState.themeMode,
          locale: appState.locale,
          supportedLocales: const [Locale('en'), Locale('es')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: appState.isAuthenticated
              ? const MainLayout()
              : const LoginScreen(),
        );
      },
    );
  }
}
