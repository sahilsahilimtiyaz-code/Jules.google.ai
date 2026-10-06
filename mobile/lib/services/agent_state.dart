import 'package:flutter/material.dart';

/// Single source of truth: is the Jules agent actively working/coding?
/// The conical glow border is ON while [isWorking], OFF when idle.
class AgentState extends ChangeNotifier {
  bool _working = false;

  /// True while any tracked session is running/queued.
  bool get isWorking => _working;

  /// Sets working state (idempotent — no rebuild if unchanged).
  void setWorking(bool v) {
    if (_working == v) return;
    _working = v;
    notifyListeners();
  }

  /// Derives working state from raw session maps (tolerates unknowns).
  void syncFromSessions(List<dynamic> sessions) {
    var working = false;
    for (final s in sessions) {
      if (s is! Map) continue;
      final st = (s['state'] ?? s['status'] ?? '').toString().toLowerCase();
      if (st.contains('run') ||
          st.contains('work') ||
          st.contains('progress') ||
          st.contains('pending') ||
          st.contains('active') ||
          st.contains('creating') ||
          st.contains('queued')) {
        working = true;
        break;
      }
    }
    setWorking(working);
  }
}
