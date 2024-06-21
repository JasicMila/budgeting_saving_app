import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    primaryColor: const Color(0xFF4A148C), // Dark Purple
    hintColor: const Color(0xFF1B5E20), // Dark Green
    textTheme: TextTheme(
      displayLarge: const TextStyle(color: Colors.yellow, fontSize: 24, fontWeight: FontWeight.bold),
      titleLarge: const TextStyle(color: Colors.yellow, fontSize: 20, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(color: Colors.yellow.withOpacity(0.8), fontSize: 18),
      bodyLarge: const TextStyle(color: Colors.yellow, fontSize: 16),
      bodyMedium: TextStyle(color: Colors.yellow.withOpacity(0.8), fontSize: 14),
      bodySmall: TextStyle(color: Colors.yellow.withOpacity(0.6), fontSize: 13),
    ),
    appBarTheme: const AppBarTheme(
      color: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.yellow),
      titleTextStyle: TextStyle(
        color: Colors.yellow,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      labelStyle: TextStyle(color: Colors.yellow),
      hintStyle: TextStyle(color: Colors.yellow),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
      ),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.yellow),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: Colors.yellow,
      unselectedItemColor: Colors.yellow,
      backgroundColor: Color(0x99A5D6A7), // Light green with transparency
    ),
  );
}
