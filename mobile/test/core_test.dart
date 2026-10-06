import 'package:flutter_test/flutter_test.dart';
import 'package:jules/src/core/validators.dart';
import 'package:jules/src/core/result.dart';

void main() {
  group('Validators', () {
    test('repo full name', () {
      expect(Validators.isRepoFullName('o/r'), true);
      expect(Validators.isRepoFullName('google-labs-code/jules-action'), true);
      expect(Validators.isRepoFullName(''), false);
      expect(Validators.isRepoFullName('justrepo'), false);
      expect(Validators.isRepoFullName('a/b/c'), false);
      expect(Validators.isRepoFullName('a b/c'), false);
    });

    test('prompt valid', () {
      expect(Validators.isPromptValid('fix it'), true);
      expect(Validators.isPromptValid('   '), false);
      expect(Validators.isPromptValid('', ), false);
    });

    test('api key shape', () {
      expect(Validators.looksLikeApiKey('short'), false);
      expect(Validators.looksLikeApiKey('x' * 20), true);
    });
  });

  group('withRetries', () {
    test('succeeds first try', () async {
      final r = await withRetries(() async => 42);
      expect(r, isA<Ok<int>>());
      expect((r as Ok<int>).value, 42);
    });

    test('retries then succeeds', () async {
      var n = 0;
      final r = await withRetries(() async {
        n++;
        if (n < 3) throw Exception('boom');
        return 'ok';
      }, attempts: 3, backoff: (_) => Duration.zero);
      expect(r, isA<Ok<String>>());
      expect(n, 3);
    });

    test('fails after attempts', () async {
      final r = await withRetries<String>(() async => throw Exception('x'),
          attempts: 2, backoff: (_) => Duration.zero);
      expect(r, isA<Err<String>>());
    });
  });
}
