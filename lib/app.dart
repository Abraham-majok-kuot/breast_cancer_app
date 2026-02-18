import 'package:flutter/material.dart';
import 'core/routes.dart';
import 'core/theme.dart';

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
