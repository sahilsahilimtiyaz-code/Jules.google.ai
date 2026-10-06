import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStore {
  static const _apiKey = 'jules_api_key';
  static const _repo = 'default_repo';
  static const _branch = 'default_branch';
  final _s = const FlutterSecureStorage();

  Future<void> saveApiKey(String v) => _s.write(key: _apiKey, value: v);
  Future<String?> getApiKey() => _s.read(key: _apiKey);
  Future<void> saveRepo(String v) => _s.write(key: _repo, value: v);
  Future<String?> getRepo() => _s.read(key: _repo);
  Future<void> saveBranch(String v) => _s.write(key: _branch, value: v);
  Future<String?> getBranch() => _s.read(key: _branch);
  Future<void> clear() => _s.deleteAll();
}
