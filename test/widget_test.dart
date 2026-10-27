import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:su_ky_mobile/app/app.dart';
import 'package:su_ky_mobile/core/config/app_config.dart';
import 'package:su_ky_mobile/core/di/providers.dart';

void main() {
  testWidgets('app boots to home and counter increments', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(
            AppConfig(
              environment: AppEnvironment.dev,
              apiBaseUrl: Uri.parse('https://api.example.com/'),
            ),
          ),
        ],
        child: const App(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Taps: 0'), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();
    expect(find.text('Taps: 1'), findsOneWidget);
  });
}
