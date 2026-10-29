import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:su_ky_mobile/features/search/ui/search_view_model.dart';

void main() {
  test('search matches trimmed case-insensitive text and clears history', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final sub = container.listen(searchViewModelProvider, (_, _) {});
    final vm = container.read(searchViewModelProvider.notifier);
    vm.query(' BẠCH ĐẰNG ');
    expect(vm.matches('Đại thắng Bạch Đằng 938'), isTrue);
    expect(vm.matches('Hào khí Đông A'), isFalse);
    vm.clearHistory();
    expect(sub.read().requireValue.recent, isEmpty);
  });
}
