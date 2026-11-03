import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:su_ky_mobile/features/auth/ui/login_view_model.dart';

void main() {
  test('login rejects invalid input and accepts valid demo form', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final sub = container.listen(loginViewModelProvider, (_, _) {});
    final vm = container.read(loginViewModelProvider.notifier);
    expect(vm.submit(), isFalse);
    expect(sub.read().requireValue.invalid, isTrue);
    vm.email('student@example.com');
    vm.password('example123');
    expect(vm.submit(), isTrue);
    expect(sub.read().requireValue.invalid, isFalse);
  });

  test('login rejects malformed email and too-short password', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.listen(loginViewModelProvider, (_, _) {});
    final vm = container.read(loginViewModelProvider.notifier);
    vm.email('not-an-email');
    vm.password('x' * minPasswordLength);
    expect(vm.submit(), isFalse);
    vm.email('student@example.com');
    vm.password('x' * (minPasswordLength - 1));
    expect(vm.submit(), isFalse);
    vm.password('x' * minPasswordLength);
    expect(vm.submit(), isTrue);
  });
}
