import 'package:flutter/services.dart';

/// Central haptics so intensity stays consistent across the app.
abstract final class Haptics {
  static Future<void> tap() => HapticFeedback.selectionClick();
  static Future<void> press() => HapticFeedback.lightImpact();
  static Future<void> confirm() => HapticFeedback.mediumImpact();
}
