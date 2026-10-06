import 'package:flutter/material.dart';

/// App-wide light/dark mode. Defaults to AMOLED dark.
class ThemeState extends ChangeNotifier {
  bool _dark = true;

  /// Current brightness choice.
  bool get isDark => _dark;

  /// Material [ThemeMode] derived from [_dark].
  ThemeMode get mode => _dark ? ThemeMode.dark : ThemeMode.light;

  /// Flips theme and notifies listeners.
  void toggle() {
    _dark = !_dark;
    notifyListeners();
  }
}
