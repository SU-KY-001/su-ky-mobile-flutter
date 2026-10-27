/// Domain-level error. Data layer maps raw exceptions (IO, HTTP, SQL) to one
/// of these so the UI never depends on transport details.
sealed class AppException implements Exception {
  const AppException(this.message, {this.cause});

  final String message;
  final Object? cause;

  /// Whether retrying the same operation can plausibly succeed.
  bool get isRetryable;

  @override
  String toString() => '$runtimeType: $message';
}

/// Transient failure (timeout, connectivity, 5xx). Safe to retry.
final class NetworkException extends AppException {
  const NetworkException(super.message, {super.cause});
  @override
  bool get isRetryable => true;
}

/// Input or server rejected the request (validation, 4xx). Do not retry.
final class ValidationException extends AppException {
  const ValidationException(super.message, {super.cause});
  @override
  bool get isRetryable => false;
}

/// Local storage failure.
final class StorageException extends AppException {
  const StorageException(super.message, {super.cause});
  @override
  bool get isRetryable => false;
}

/// Anything unmapped. Always log with the cause.
final class UnknownException extends AppException {
  const UnknownException(super.message, {super.cause});
  @override
  bool get isRetryable => false;
}
