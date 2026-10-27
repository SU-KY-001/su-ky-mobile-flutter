import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'core/config/app_config.dart';
import 'core/di/providers.dart';
import 'core/logging/app_logger.dart';

Future<void> main() async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      final config = AppConfig.fromEnvironment();
      AppLogger.configure(config);
      FlutterError.onError = (details) => AppLogger.error(
        'Flutter framework error',
        error: details.exception,
        stackTrace: details.stack,
      );
      PlatformDispatcher.instance.onError = (error, stack) {
        AppLogger.error(
          'Uncaught platform error',
          error: error,
          stackTrace: stack,
        );
        return true;
      };
      final prefs = await SharedPreferences.getInstance();
      runApp(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(config),
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: const App(),
        ),
      );
    },
    (error, stack) =>
        AppLogger.error('Uncaught zone error', error: error, stackTrace: stack),
  );
}
