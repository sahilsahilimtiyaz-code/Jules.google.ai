/// Powerful prompt presets that make Jules code stronger.
/// Each wraps the user's raw task with architecture, verification and guardrails.
class PromptPreset {
  final String id;
  final String label;
  final String icon;
  final String description;
  final String Function(String task, String repo, String branch) build;
  const PromptPreset({required this.id, required this.label, required this.icon, required this.description, required this.build});
}

String _base(String task, String repo, String branch) => '''
REPO: $repo @ $branch
TASK: $task
''';

String _guardrails({bool strictTests = true, int maxLines = 250}) => '''
GUARDRAILS:
- Keep diff under $maxLines lines. Small focused PRs only.
- Don't change public API contracts unless asked.
- No hardcoded secrets. No leftover markers left in code.
${strictTests ? '- All existing tests must pass. Add/adjust tests for new behavior.\n- Run the relevant test command before finishing.' : '- Run relevant checks if available.'}
- Verify your own work: re-read the diff, run the app/tests, fix failures before opening PR.
''';

String _verifyLoop(String how) => '''
VERIFY LOOP:
1. Reproduce / understand: $how
2. Implement minimal fix
3. Re-run verification (tests, build, bench)
4. If failing, iterate max 3 times, then summarize blockers in PR body
5. PR body must include: What changed, How verified, Risk, Follow-ups
''';

const List<PromptPreset> kPresets = [
  PromptPreset(
    id: 'architect',
    label: 'Architect',
    icon: '🏗️',
    description: 'Best default. Plans, implements, verifies.',
    build: _architect,
  ),
  PromptPreset(
    id: 'bug',
    label: 'Bug Hunter',
    icon: '🐞',
    description: 'Repro, root cause, minimal fix + regression test.',
    build: _bug,
  ),
  PromptPreset(
    id: 'perf',
    label: 'Perf Optimizer',
    icon: '⚡',
    description: 'Bench before/after, measurable gains only.',
    build: _perf,
  ),
  PromptPreset(
    id: 'security',
    label: 'Security Auditor',
    icon: '🛡️',
    description: 'Hunts vulns, fixes by severity.',
    build: _security,
  ),
  PromptPreset(
    id: 'tests',
    label: 'Test Writer',
    icon: '🧪',
    description: 'Fills coverage gaps to 85%+.',
    build: _tests,
  ),
  PromptPreset(
    id: 'refactor',
    label: 'Clean Refactor',
    icon: '✨',
    description: 'Small safe cleanups, no behavior change.',
    build: _refactor,
  ),
];

String _architect(String task, String repo, String branch) => '''
You are a senior staff engineer agent.
${_base(task, repo, branch)}
PROTOCOL:
1. Map the codebase: find entry points, owners of the touched area, existing patterns.
2. Write a 5-9 step plan in the PR body first.
3. Implement in small commits: types -> logic -> wiring -> tests.
4. Prefer editing existing code over new abstractions.
${_guardrails(strictTests: true)}
${_verifyLoop('run the closest test suite + build')}
''';

String _bug(String task, String repo, String branch) => '''
You are a bug-hunting agent.
${_base(task, repo, branch)}
PROTOCOL:
1. Reproduce first: find failing test / log / stack, or create a minimal repro.
2. Root-cause: trace to the exact lines, cite files:line.
3. Fix minimal: one root cause, no drive-by refactors.
4. Add regression test that fails without the fix.
${_guardrails(strictTests: true, maxLines: 150)}
${_verifyLoop('run the repro + related tests')}
''';

String _perf(String task, String repo, String branch) => '''
You are a performance agent. Only open a PR if you achieve measurable gains.
${_base(task, repo, branch)}
PROTOCOL:
1. Bench first: run existing bench / profile slowest path.
2. Target top 1 bottleneck (algo, N+1 query, rebuild, allocation).
3. Optimize: cache, batch, lazy-load, reduce complexity.
4. Re-bench and report before/after numbers in PR.
${_guardrails(strictTests: true)}
${_verifyLoop('bench + tests')}
CONSTRAINT: No PR if no measurable gain or tests regress.
''';

String _security(String task, String repo, String branch) => '''
You are a security agent. Fix highest severity first.
${_base(task, repo, branch)}
CHECK:
CRITICAL: hardcoded secrets, SQL/command injection, missing auth on sensitive routes.
HIGH: XSS, CSRF, IDOR, mass assignment, insecure deserialization, missing validation.
MEDIUM: verbose errors, weak crypto, open redirects.
${_guardrails(strictTests: true, maxLines: 120)}
${_verifyLoop('run security checks + tests (e.g. npm audit / flutter analyze if present)')}
''';

String _tests(String task, String repo, String branch) => '''
You are a test-coverage agent. Target 85%+ on touched files.
${_base(task, repo, branch)}
PROTOCOL:
1. Find untested branches in touched area.
2. Add unit/widget tests: happy path + edge + error.
3. Keep tests fast and hermetic, no network.
${_guardrails(strictTests: true)}
${_verifyLoop('run new tests + full related suite')}
''';

String _refactor(String task, String repo, String branch) => '''
You are a cleanup agent. No behavior changes.
${_base(task, repo, branch)}
ALLOW: dead code, dup logic, naming, long functions split, lint fixes.
FORBID: API changes, dep upgrades, logic rewrites.
${_guardrails(strictTests: true, maxLines: 200)}
${_verifyLoop('run tests + analyze')}
''';

/// Power wrapper: adds repo context hints + strict output contract
String buildPowerPrompt({
  required String presetId,
  required String task,
  required String repo,
  required String branch,
  required bool deepContext,
  required bool includeHistory,
  required bool strict,
}) {
  final p = kPresets.firstWhere((e) => e.id == presetId, orElse: () => kPresets.first);
  var out = p.build(task, repo, branch);
  if (deepContext) {
    out += '\nDEEP CONTEXT:\n- List the file tree 2 levels around touched files.\n- Read similar existing implementations before writing new code.\n- Match code style, null-safety, error handling of neighbors.\n';
  }
  if (includeHistory) {
    out += '\nHISTORY:\n- Consider recent commit messages for intent; avoid reverting recent fixes.\n';
  }
  if (strict) {
    out += '\nSTRICT MODE:\n- If ambiguous, choose the safest minimal change and note alternatives in PR.\n- Never leave the repo red. Never force-push. Never commit API keys.\n';
  }
  return out.trim();
}
