import 'package:flutter/material.dart';

/// Global singleton that holds reactive theme & language state.
/// Use [ValueListenableBuilder] or listen directly to the notifiers.
class AppSettings {
  AppSettings._();
  static final AppSettings instance = AppSettings._();

  final ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.light);
  final ValueNotifier<String> language = ValueNotifier('English');

  bool get isDarkMode => themeMode.value == ThemeMode.dark;

  void setDarkMode(bool dark) {
    themeMode.value = dark ? ThemeMode.dark : ThemeMode.light;
  }

  void setLanguage(String lang) {
    language.value = lang;
  }
}
