import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:su_ky_mobile/shared/audio/audio_view_model.dart';

void main() {
  test('playback seeks clamp and episode changes reset position', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final vm = container.read(audioViewModelProvider.notifier);
    vm.seek(2);
    expect(
      container.read(audioViewModelProvider).position,
      container.read(audioViewModelProvider).duration,
    );
    vm.playEpisode(2);
    expect(container.read(audioViewModelProvider).position, 0);
    expect(container.read(audioViewModelProvider).playing, isTrue);
    vm.skip(-15);
    expect(container.read(audioViewModelProvider).position, 0);
    vm.toggle();
    expect(container.read(audioViewModelProvider).playing, isFalse);
  });
}
