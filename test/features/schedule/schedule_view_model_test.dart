import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:su_ky_mobile/features/schedule/data/schedule_providers.dart';
import 'package:su_ky_mobile/features/schedule/ui/schedule_view_model.dart';

ProviderContainer _container(DateTime now) {
  final container = ProviderContainer(
    overrides: [scheduleClockProvider.overrideWithValue(() => now)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('starts at the current month', () {
    final container = _container(DateTime(2026, 11, 15, 10, 30));

    expect(container.read(scheduleViewModelProvider), DateTime(2026, 11));
  });

  test('previous and next stay on the first day of the month', () {
    final container = _container(DateTime(2026, 11, 15));
    final model = container.read(scheduleViewModelProvider.notifier);

    model.next();
    expect(container.read(scheduleViewModelProvider), DateTime(2026, 12));
    model.next();
    expect(container.read(scheduleViewModelProvider), DateTime(2027, 1));
    model.previous();
    expect(container.read(scheduleViewModelProvider), DateTime(2026, 12));
  });

  test('previous crosses into the previous year', () {
    final container = _container(DateTime(2026, 1, 31));
    final model = container.read(scheduleViewModelProvider.notifier);

    model.previous();

    expect(container.read(scheduleViewModelProvider), DateTime(2025, 12));
  });
}
