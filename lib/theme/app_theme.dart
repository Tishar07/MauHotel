import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryBlue = Color(0xFF0D47A1);
  static const Color lightBlue = Color(0xFFE3F2FD);
  static const Color accentBlue = Color(0xFF1976D2);

  static ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: Colors.white,

    colorScheme: const ColorScheme.light(
      primary: primaryBlue,
      secondary: accentBlue,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
      ),
    ),

    cardTheme: CardThemeData(
      color: const Color.fromARGB(255, 131, 186, 224),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 2,
    ),
  );
}
