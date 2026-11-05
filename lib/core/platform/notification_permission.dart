import 'package:flutter/services.dart';

import '../logging/app_logger.dart';

const _channel = MethodChannel('su_ky_mobile/notification_permission');
const _requestMethod = 'request';
const _requestTimeout = Duration(minutes: 2);

/// Asks for the Android 13+ notification permission so the playback
/// notification can show. Returns false on denial or platform failure;
/// playback works either way, only the notification is lost.
Future<bool> requestNotificationPermission() async {
  try {
    final granted = await _channel
        .invokeMethod<bool>(_requestMethod)
        .timeout(_requestTimeout);
    return granted ?? false;
  } on Object catch (error, stackTrace) {
    AppLogger.error(
      'Notification permission request failed',
      error: error,
      stackTrace: stackTrace,
    );
    return false;
  }
}
