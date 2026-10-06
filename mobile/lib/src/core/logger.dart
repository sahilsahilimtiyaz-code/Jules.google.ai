import 'package:flutter/foundation.dart';

/// Minimal structured logger. Debug-only verbose, release-safe.
abstract final class AppLog {
  static void info(String message) {
    if (kDebugMode) debugPrint('[INFO] $message');
  }

  static void warn(String message) {
    debugPrint('[WARN] $message');
  }

  static void error(String message, [Object? cause]) {
    debugPrint('[ERROR] $message${cause == null ? '' : ' cause=$cause'}');
  }
}
