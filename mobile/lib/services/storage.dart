import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// On-device secure persistence. Secrets never leave the phone except
/// as API headers — never committed, never logged.
class SecureStore {
  static const _apiKey = 'jules_api_key';
  static const _repo = 'default_repo';
  static const _branch = 'default_branch';

  final FlutterSecureStorage _s;
  SecureStore([FlutterSecureStorage? storage])
      : _s = storage ?? const FlutterSecureStorage();

  Future<void> saveApiKey(String v) => _s.write(key: _apiKey, value: v);
  Future<String?> getApiKey() => _s.read(key: _apiKey);
  Future<void> saveRepo(String v) => _s.write(key: _repo, value: v);
  Future<String?> getRepo() => _s.read(key: _repo);
  Future<void> saveBranch(String v) => _s.write(key: _branch, value: v);
  Future<String?> getBranch() => _s.read(key: _branch);

  /// Clears all stored values (e.g. sign-out / key rotation).
  Future<void> clear() => _s.deleteAll();
}
