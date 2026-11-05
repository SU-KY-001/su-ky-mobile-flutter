import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:su_ky_mobile/features/auth/ui/auth_form_view_model.dart';
import 'package:su_ky_mobile/features/auth/ui/login_screen.dart';
import 'package:su_ky_mobile/l10n/gen/app_localizations.dart';

const _emailKey = ValueKey('auth.field.email');
const _nameKey = ValueKey('auth.field.name');
const _signInPasswordKey = ValueKey('auth.field.password.signIn');
const _signUpPasswordKey = ValueKey('auth.field.password.signUp');

String _fieldText(WidgetTester tester, Key key) => tester
    .widget<EditableText>(
      find.descendant(of: find.byKey(key), matching: find.byType(EditableText)),
    )
    .controller
    .text;

Future<ProviderContainer> _pumpLogin(WidgetTester tester) async {
  tester.view.physicalSize = const Size(800, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final container = ProviderContainer();
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const LoginScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

AppLocalizations _l(WidgetTester tester) =>
    AppLocalizations.of(tester.element(find.byType(LoginScreen)));

Future<void> _tapFooter(WidgetTester tester, String label) async {
  final target = find.text(label);
  await tester.ensureVisible(target);
  await tester.tap(target);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'switching sign-up to sign-in keeps the email and clears name/password',
    (tester) async {
      final container = await _pumpLogin(tester);
      final l = _l(tester);

      await _tapFooter(tester, l.register);
      expect(find.byKey(_nameKey), findsOneWidget);

      await tester.enterText(find.byKey(_nameKey), 'Ann');
      await tester.enterText(find.byKey(_emailKey), 'a@b.co');
      await tester.enterText(find.byKey(_signUpPasswordKey), 'secret123');
      await tester.pump();

      await _tapFooter(tester, l.signIn);

      expect(find.byKey(_nameKey), findsNothing);
      expect(
        _fieldText(tester, _emailKey),
        'a@b.co',
        reason: 'the field must match the email the model keeps',
      );
      expect(_fieldText(tester, _signInPasswordKey), isEmpty);

      final form = container.read(authFormViewModelProvider);
      expect(form.name, isEmpty);
      expect(form.password, isEmpty);
    },
  );

  testWidgets('switching back to sign-up starts with an empty name', (
    tester,
  ) async {
    await _pumpLogin(tester);
    final l = _l(tester);

    await _tapFooter(tester, l.register);
    await tester.enterText(find.byKey(_nameKey), 'Ann');
    await tester.pump();
    await _tapFooter(tester, l.signIn);
    await _tapFooter(tester, l.register);

    expect(_fieldText(tester, _nameKey), isEmpty);
  });
}
