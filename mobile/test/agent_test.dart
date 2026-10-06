import 'package:flutter_test/flutter_test.dart';
import 'package:jules/services/agent_state.dart';

void main() {
  test('agent sync detects working states', () {
    final a = AgentState();
    expect(a.isWorking, false);
    a.syncFromSessions([
      {'state': 'COMPLETED'},
    ]);
    expect(a.isWorking, false);
    a.syncFromSessions([
      {'state': 'RUNNING'},
    ]);
    expect(a.isWorking, true);
    a.syncFromSessions([]);
    expect(a.isWorking, false);
  });

  test('manual toggle', () {
    final a = AgentState();
    a.setWorking(true);
    expect(a.isWorking, true);
    a.setWorking(true); // idempotent
    expect(a.isWorking, true);
    a.setWorking(false);
    expect(a.isWorking, false);
  });
}
