import 'package:flutter/material.dart';

/// ثيم بسيط وحديث، قابل للتوسع لاحقًا.
class AppTheme {
  static const primaryColor = Color(0xFF0F766E); // أخضر مموه هادئ
  static const secondaryColor = Color(0xFFF59E0B);

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
        fontFamily: 'Cairo', // أضف خط عربي مناسب لاحقًا في pubspec
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
}
