import 'package:flutter/material.dart';
import '../views/splash_screen.dart';
import '../views/dashboard_screen.dart';
import '../views/prediction_screen.dart';
import '../views/result_screen.dart';
import '../views/register_screen.dart';
import '../views/login_screen.dart';
import '../views/auth_screen.dart';

class Routes {
  static const String splash = '/';
  static const String register = '/register';
  static const String login = '/login';
  static const String input = '/input';
  static const String result = '/result';
  static const String settings = '/settings';
  static const String auth = '/auth';
  static const String dashboard = '/dashboard';

  static final Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    register: (context) => const RegisterScreen(),
    input: (context) => const Placeholder(),
    result: (context) => const Placeholder(),
    settings: (context) => const Placeholder(),
    auth: (context) => const AuthScreen(),
    login: (context) => const LoginScreen(),
    dashboard: (context) => const DashboardScreen(),
  };
}