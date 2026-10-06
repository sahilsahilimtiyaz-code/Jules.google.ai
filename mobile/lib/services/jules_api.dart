import 'dart:convert';
import 'package:http/http.dart' as http;

// Powerful client: same backend as action.yaml, with retries + modes.
// POST https://jules.googleapis.com/v1alpha/sessions
class JulesApi {
  static const base = 'https://jules.googleapis.com/v1alpha';
  final String apiKey;
  JulesApi(this.apiKey);

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'X-Goog-Api-Key': apiKey,
  };

  Future<Map<String, dynamic>> createSession({
    required String prompt,
    required String repoFullName,
    String startingBranch = 'main',
    bool requirePlanApproval = false,
    String automationMode = 'AUTO_CREATE_PR', // or ASK_FOR_APPROVAL
    String? extraContext, // git show / logs / pasted code
  }) async {
    var fullPrompt = prompt;
    if (extraContext != null && extraContext.trim().isNotEmpty) {
      fullPrompt += '\n\n--- EXTRA CONTEXT (git show / logs / snippets) ---\n```\n${extraContext.trim()}\n```';
    }
    final body = {
      'prompt': fullPrompt,
      'sourceContext': {
        'source': 'sources/github/$repoFullName',
        'githubRepoContext': {'startingBranch': startingBranch}
      },
      'requirePlanApproval': requirePlanApproval,
      'automationMode': automationMode,
    };
    Exception? last;
    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        final res = await http.post(
          Uri.parse('$base/sessions'),
          headers: _headers,
          body: jsonEncode(body),
        ).timeout(const Duration(seconds: 30));
        if (res.statusCode >= 200 && res.statusCode < 300) {
          return jsonDecode(res.body) as Map<String, dynamic>;
        }
        if (res.statusCode >= 500 && attempt < 2) {
          await Future.delayed(Duration(seconds: 2 << attempt));
          continue;
        }
        throw Exception('Jules ${res.statusCode}: ${res.body}');
      } catch (e) {
        last = e is Exception ? e : Exception(e.toString());
        if (attempt < 2) await Future.delayed(Duration(seconds: 2 << attempt));
      }
    }
    throw last ?? Exception('Jules create failed');
  }

  Future<List<dynamic>> listSessions() async {
    final res = await http.get(Uri.parse('$base/sessions'), headers: _headers)
      .timeout(const Duration(seconds: 30));
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body);
      if (data is Map && data['sessions'] is List) return data['sessions'];
      if (data is List) return data;
      return [data];
    }
    throw Exception('Jules list ${res.statusCode}: ${res.body}');
  }
}
