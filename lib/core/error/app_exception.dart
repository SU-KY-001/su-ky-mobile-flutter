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

/// Server rejected the request (4xx). [errorCode] is the API's machine code
/// (`error_code` or `code`); callers branch on it, never on [message].
final class ApiException extends AppException {
  const ApiException(
    super.message, {
    required this.statusCode,
    this.errorCode,
    super.cause,
  });

  final int statusCode;
  final String? errorCode;

  @override
  bool get isRetryable => retryableErrorCodes.contains(errorCode);
}

/// API codes that are safe to retry with the same request.
const retryableErrorCodes = {
  'RATE_LIMITED',
  'IDEMPOTENCY_REQUEST_IN_PROGRESS',
  'MEDIA_PROVIDER_UNAVAILABLE',
};

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
