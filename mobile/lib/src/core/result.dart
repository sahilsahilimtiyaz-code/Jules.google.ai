/// Typed result for async operations. Forces callers to handle failure.
sealed class Result<T> {
  const Result();
}

/// Success path carrying [value].
final class Ok<T> extends Result<T> {
  final T value;
  const Ok(this.value);
}

/// Failure path carrying a human-readable [message] + optional [cause].
final class Err<T> extends Result<T> {
  final String message;
  final Object? cause;
  const Err(this.message, [this.cause]);
}

/// Runs [fn] with retries + exponential backoff, returning a [Result].
Future<Result<T>> withRetries<T>(
  Future<T> Function() fn, {
  int attempts = 3,
  Duration Function(int attempt)? backoff,
}) async {
  Object? last;
  for (var i = 0; i < attempts; i++) {
    try {
      return Ok(await fn());
    } catch (e) {
      last = e;
      if (i < attempts - 1) {
        await Future.delayed(
            backoff?.call(i) ?? Duration(seconds: 2 << i));
      }
    }
  }
  return Err('Failed after $attempts attempts', last);
}
