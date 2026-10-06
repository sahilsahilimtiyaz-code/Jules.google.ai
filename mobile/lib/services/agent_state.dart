import 'package:flutter/material.dart';

// Single source of truth: is the Jules agent actively working/coding?
// Glow ON when true, OFF when false.
class AgentState extends ChangeNotifier {
  bool _working = false;
  bool get isWorking => _working;

  void setWorking(bool v) {
    if (_working == v) return;
    _working = v;
    notifyListeners();
  }

  // Infer from Jules session states
  void syncFromSessions(List<dynamic> sessions) {
    bool working = false;
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
