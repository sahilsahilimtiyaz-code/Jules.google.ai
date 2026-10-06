import 'package:flutter/material.dart';

class ThemeState extends ChangeNotifier {
  bool _dark = true;
  bool get isDark => _dark;
  ThemeMode get mode => _dark ? ThemeMode.dark : ThemeMode.light;
  void toggle() { _dark = !_dark; notifyListeners(); }
}
