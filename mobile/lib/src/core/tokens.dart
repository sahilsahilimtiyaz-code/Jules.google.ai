import 'package:flutter/material.dart';

/// Brand + semantic color tokens. Single source of truth — no hex in screens.
abstract final class AppColors {
  static const primary = Color(0xFF715CD7);
  static const secondary = Color(0xFF3B82F6);
  static const tertiary = Color(0xFFB388FF);

  static const success = Color(0xFF22C55E);
  static const successBright = Color(0xFF4ADE80);
  static const danger = Color(0xFFEF4444);
  static const warning = Color(0xFFF59E0B);

  /// Endless conical glow loop: blue → green → purple → red → white → violet.
  static const glowLoop = [
    Color(0xFF3B82F6),
    Color(0xFF22C55E),
    Color(0xFFA855F7),
    Color(0xFFEF4444),
    Color(0xFFFFFFFF),
    Color(0xFF8B5CF6),
    Color(0xFF3B82F6),
  ];

  static const amoled = Colors.black;
  static const ink = Color(0xFF0A0A0A);
  static const paper = Color(0xFFF6F4FF);
}

/// 4pt spacing scale.
abstract final class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 28.0;
  static const bottomBarClearance = 120.0;
}

/// Corner radii.
abstract final class AppRadius {
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 22.0;
  static const xl = 28.0;
  static const pill = 999.0;
}

/// Standard animation durations.
abstract final class AppDurations {
  static const fast = Duration(milliseconds: 200);
  static const normal = Duration(milliseconds: 350);
  static const slow = Duration(milliseconds: 600);
  static const splash = Duration(milliseconds: 2100);
  static const glowLoop = Duration(seconds: 3);
}

/// API + app constants. No magic strings in services/screens.
abstract final class AppConstants {
  static const julesWebUrl = 'https://jules.google.com';
  static const julesApiBase = 'https://jules.googleapis.com/v1alpha';
  static const packageBase = 'octavian.com';
  static const appName = 'jules';
  static const maxPromptChars = 12000;
  static const httpTimeout = Duration(seconds: 30);
  static const maxRetries = 3;
}
