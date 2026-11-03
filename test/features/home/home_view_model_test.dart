import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:su_ky_mobile/features/home/ui/home_view_model.dart';

void main() {
  test('category selection ignores invalid indices', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final sub = container.listen(homeViewModelProvider, (_, _) {});
    expect(sub.read(), 0);

    container.read(homeViewModelProvider.notifier).selectCategory(2);
    expect(sub.read(), 2);
    container.read(homeViewModelProvider.notifier).selectCategory(-1);
    expect(sub.read(), 2);
    container
        .read(homeViewModelProvider.notifier)
        .selectCategory(homeCategoryCount);
    expect(sub.read(), 2);
  });
}
