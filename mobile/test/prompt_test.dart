import 'package:flutter_test/flutter_test.dart';
import 'package:jules/services/prompt_library.dart';

void main() {
  test('presets exist', () {
    expect(kPresets.length, greaterThanOrEqualTo(6));
    expect(kPresets.map((e) => e.id), contains('architect'));
  });

  test('power prompt contains guardrails + verify loop', () {
    final p = buildPowerPrompt(
      presetId: 'bug', task: 'Fix login crash',
      repo: 'o/r', branch: 'main',
      deepContext: true, includeHistory: false, strict: true,
    );
    expect(p, contains('Fix login crash'));
    expect(p, contains('GUARDRAILS'));
    expect(p, contains('VERIFY LOOP'));
    expect(p, contains('DEEP CONTEXT'));
  });

  test('unknown preset falls back to architect', () {
    final p = buildPowerPrompt(
      presetId: 'nope', task: 't', repo: 'o/r', branch: 'main',
      deepContext: false, includeHistory: false, strict: false,
    );
    expect(p.isNotEmpty, true);
  });
}
