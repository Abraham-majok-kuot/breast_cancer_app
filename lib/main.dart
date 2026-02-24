import 'package:flutter/material.dart';
import 'app.dart';
import 'app_routes/routes.dart';
import 'core/theme/theme.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Breast Cancer Prediction',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      initialRoute: Routes.splash,
      routes: Routes.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}

