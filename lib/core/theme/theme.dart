import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    primaryColor: Colors.green,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.green,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    scaffoldBackgroundColor: Colors.pink, // Pink background for all screens
    colorScheme: ColorScheme.fromSwatch().copyWith(
      secondary: Colors.green,
      primary: Colors.green,
    ),
  );

  static final ThemeData darkTheme = ThemeData.dark();
}
