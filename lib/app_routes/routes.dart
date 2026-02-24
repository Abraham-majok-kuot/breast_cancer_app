import 'package:flutter/material.dart';
import '../views/splash_screen.dart';
import '../views/dashboard_screen.dart';
import '../views/prediction_screen.dart';
import '../views/result_screen.dart';
class Routes {
  static const String splash = '/';
  static const String register = '/register';
  static const String input = '/input';
  static const String result = '/result';
  static const String settings = '/settings';

  static final Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    register: (context) => const Placeholder(),
    input: (context) => const Placeholder(),
    result: (context) => const Placeholder(),
    settings: (context) => const Placeholder(),
  };
}