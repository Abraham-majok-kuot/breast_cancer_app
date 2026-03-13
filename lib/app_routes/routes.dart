import 'package:breast_cancer_app/views/analytics_screen.dart';
import 'package:breast_cancer_app/views/newsletter_screen.dart';
import 'package:flutter/material.dart';
import '../views/splash_screen.dart';
import '../views/dashboard_screen.dart';
import '../views/register_screen.dart';
import '../views/login_screen.dart';
import '../views/auth_screen.dart';
import '../views/settings_screen.dart';
import '../views/reset_password_screen.dart';
import '../views/education_screen.dart';
import '../views/prediction_screen.dart';
import '../views/result_screen.dart';
import '../views/history_screen.dart';

class Routes {
  static const String splash      = '/';
  static const String register    = '/register';
  static const String login       = '/login';
  static const String auth        = '/auth';
  static const String dashboard   = '/dashboard';
  static const String input       = '/input';
  static const String result      = '/result';
  static const String settings    = '/settings';
  static const String resetPass   = '/reset-password';
  static const String education   = '/education';
  static const String history     = '/history';
  static const  String newsletter  = '/newsletter';
  static const String analytics    = '/analytics';
  

  static final Map<String, WidgetBuilder> routes = {
    splash:      (context) => const SplashScreen(),
    register:    (context) => const RegisterScreen(),
    login:       (context) => const LoginScreen(),
    auth:        (context) => const AuthScreen(),
    dashboard:   (context) => const DashboardScreen(),
    input:       (context) => const PredictionScreen(),
    result:      (context) => const ResultScreen(),
    settings:    (context) => const SettingsScreen(),
    resetPass:   (context) => const ResetPasswordScreen(),
    education:   (context) => const EducationScreen(),
    history:     (context) => const HistoryScreen(),
    newsletter: (context) => const NewsletterScreen(),
    analytics: (context) => const AnalyticsScreen(),
  };
}