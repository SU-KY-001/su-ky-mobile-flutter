import 'dart:developer' as developer;

import '../config/app_config.dart';

/// Thin structured-logging facade. Swap the sink here (Crashlytics, Sentry)
/// without touching call sites. Never log tokens, passwords, or PII.
abstract final class AppLogger {
  static const _name = 'su_ky';
  static const _levelInfo = 800;
  static const _levelSevere = 1000;

  static bool _verbose = true;

  static void configure(AppConfig config) => _verbose = !config.isProduction;

  static void info(String message) {
    if (_verbose) developer.log(message, name: _name, level: _levelInfo);
  }

  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    developer.log(
      message,
      name: _name,
      level: _levelSevere,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
