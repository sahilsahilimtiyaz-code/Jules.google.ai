/// Pure input validators — unit-tested, no Flutter dependency.
abstract final class Validators {
  /// `owner/repo` shape check.
  static bool isRepoFullName(String v) {
    final t = v.trim();
    if (t.isEmpty || t.contains(' ')) return false;
    final parts = t.split('/');
    return parts.length == 2 &&
        parts.every((p) => p.isNotEmpty && p.length <= 100);
  }

  /// Non-empty after trim, within [max] chars.
  static bool isPromptValid(String v, {int max = 12000}) {
    final t = v.trim();
    return t.isNotEmpty && t.length <= max;
  }

  /// API key sanity (Jules keys are long opaque strings).
  static bool looksLikeApiKey(String v) => v.trim().length >= 20;
}
