import '../error/app_exception.dart';

const retryMaxAttempts = 2;
const retryBaseDelay = Duration(milliseconds: 500);

/// Provider retry policy for `ProviderScope(retry:)`. Riverpod 3 retries every
/// failing provider up to 10 times unless told otherwise, so this is required.
/// Retries only transient failures, like the RN query client.
Duration? appRetry(int retryCount, Object error) {
  if (retryCount >= retryMaxAttempts) return null;
  if (error is AppException && !error.isRetryable) return null;
  return retryBaseDelay * (1 << retryCount);
}
