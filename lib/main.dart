import 'package:flutter/material.dart';
import 'app_routes/routes.dart';
import 'core/theme/theme.dart';
import 'core/app_settings.dart';
import 'core/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'views/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppSettings.instance.themeMode,
      builder: (_, themeMode, __) {
        return MaterialApp(
          // ── Navigator key — required for notification tap navigation ──
          navigatorKey: NotificationService.navigatorKey,

          title: 'Breast Cancer Prediction',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          initialRoute: Routes.splash,
          routes: Routes.routes,
          debugShowCheckedModeBanner: false,

          // Provide translations + RTL to every route via the builder
          builder: (ctx, child) {
            return ValueListenableBuilder<String>(
              valueListenable: AppSettings.instance.language,
              builder: (_, lang, __) {
                return AppLocalizationsProvider(
                  language: lang,
                  child: child!,
                );
              },
            );
          },
        );
      },
    );
  }
}