import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../src/core/logger.dart';
import '../src/core/result.dart';
import '../src/core/tokens.dart';

/// Typed Jules session (subset of the REST resource we render).
class JulesSession {
  final String title;
  final String state;
  final String name;
  const JulesSession(
      {required this.title, required this.state, required this.name});

  /// Best-effort parse — the API may add fields; never throws.
  factory JulesSession.fromJson(Map<String, dynamic> json) {
    return JulesSession(
      title: (json['title'] ?? json['name'] ?? 'Session').toString(),
      state: (json['state'] ?? json['status'] ?? 'unknown').toString(),
      name: (json['name'] ?? '').toString(),
    );
  }

  /// True while the cloud agent is actively working (drives the glow).
  bool get isWorking {
    final s = state.toLowerCase();
    return s.contains('run') ||
        s.contains('work') ||
        s.contains('progress') ||
        s.contains('pending') ||
        s.contains('active') ||
        s.contains('creating') ||
        s.contains('queued');
  }
}

/// REST client for the Jules API — same backend as `action.yaml`.
///
/// - `POST /v1alpha/sessions` with `X-Goog-Api-Key`
/// - payload mirrors the Action: prompt + sourceContext + automationMode
/// - retries with backoff; throws human-readable [Exception] on failure
class JulesApi {
  static const String base = AppConstants.julesApiBase;

  final String apiKey;
  final http.Client _client;
  final bool _ownsClient;

  JulesApi(this.apiKey, [http.Client? client])
      : _client = client ?? http.Client(),
        _ownsClient = client == null;

  /// Releases the internal HTTP client if owned (call on app dispose).
  void close() {
    if (_ownsClient) _client.close();
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': apiKey,
      };

  /// Creates a session. [repoFullName] must be `owner/repo`.
  Future<Map<String, dynamic>> createSession({
    required String prompt,
    required String repoFullName,
    String startingBranch = 'main',
    bool requirePlanApproval = false,
    String automationMode = 'AUTO_CREATE_PR',
    String? extraContext,
  }) async {
    var fullPrompt = prompt;
    if (extraContext != null && extraContext.trim().isNotEmpty) {
      fullPrompt +=
          '\n\n--- EXTRA CONTEXT (logs / snippets) ---\n```\n${extraContext.trim()}\n```';
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

    final result = await withRetries(
      () => _client
          .post(Uri.parse('$base/sessions'),
              headers: _headers, body: jsonEncode(body))
          .timeout(AppConstants.httpTimeout)
          .then((res) {
        if (res.statusCode >= 200 && res.statusCode < 300) {
          final decoded = jsonDecode(res.body);
          if (decoded is Map<String, dynamic>) return decoded;
          if (decoded is Map) return Map<String, dynamic>.from(decoded);
          throw Exception('Jules: unexpected response shape');
        }
        if (res.statusCode >= 500) throw TimeoutException('Jules 5xx');
        throw Exception('Jules ${res.statusCode}: ${res.body}');
      }),
      attempts: AppConstants.maxRetries,
    );

    return switch (result) {
      Ok(value: final v) => v,
      Err(message: final m, cause: final c) => throw Exception(
          c == null ? m : '$m — $c'),
    };
  }

  /// Lists sessions (raw maps; parsed to [JulesSession] by callers as needed).
  Future<List<dynamic>> listSessions() async {
    try {
      final res = await _client
          .get(Uri.parse('$base/sessions'), headers: _headers)
          .timeout(AppConstants.httpTimeout);
      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = jsonDecode(res.body);
        if (data is Map && data['sessions'] is List) {
          return data['sessions'] as List<dynamic>;
        }
        if (data is List) return data;
        return [data];
      }
      throw Exception('Jules list ${res.statusCode}: ${res.body}');
    } catch (e) {
      AppLog.error('listSessions failed', e);
      rethrow;
    }
  }
}
