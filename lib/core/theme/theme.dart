import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.pink,
    useMaterial3: true,
  );

  static ThemeData darkTheme = ThemeData.dark(useMaterial3: true);
}
