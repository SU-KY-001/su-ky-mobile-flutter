import 'app_exception.dart';

/// Explicit success/failure return for repository and service calls.
/// Callers must handle both branches via `switch`; no thrown control flow
/// across layer boundaries.
sealed class Result<T> {
  const Result();
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);
  final T value;
}

final class Err<T> extends Result<T> {
  const Err(this.error);
  final AppException error;
}
