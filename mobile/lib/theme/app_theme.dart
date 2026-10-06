import 'package:flutter/material.dart';

class AppTheme {
  static const bg = Colors.black;
  static const accent = Color(0xFF715CD7);
  static const accent2 = Color(0xFF3B82F6);
  static const accent3 = Color(0xFFB388FF);

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bg,
      colorScheme: const ColorScheme.dark(
        primary: accent, secondary: accent2, tertiary: accent3,
        background: bg, surface: Color(0xFF0A0A0A),
      ),
      appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent, elevation: 0),
      cardTheme: CardThemeData(
        color: Colors.white.withOpacity(0.06),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        elevation: 0,
      ),
      chipTheme: ChipThemeData(
        selectedColor: accent.withOpacity(0.25),
        labelStyle: const TextStyle(color: Colors.white),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true, fillColor: Colors.white.withOpacity(0.07),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: accent, width: 1.2)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accent, foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
      ),
    );
  }

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF6F4FF),
      colorScheme: const ColorScheme.light(
        primary: accent, secondary: accent2, tertiary: accent3,
        background: Color(0xFFF6F4FF), surface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent, elevation: 0,
        foregroundColor: Colors.black87),
      cardTheme: CardThemeData(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        elevation: 2,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true, fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: accent, width: 1.4)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accent, foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
      ),
    );
  }

  static const gradient = LinearGradient(
    colors: [accent, accent2], begin: Alignment.topLeft, end: Alignment.bottomRight);
  static const bgGradient = LinearGradient(
    colors: [Colors.black, Color(0xFF1a1033), Color(0xFF0b1e4b)],
    begin: Alignment.topCenter, end: Alignment.bottomCenter);
  static const bgGradientLight = LinearGradient(
    colors: [Color(0xFFF6F4FF), Color(0xFFE9E3FF), Color(0xFFDCE9FF)],
    begin: Alignment.topCenter, end: Alignment.bottomCenter);
}
