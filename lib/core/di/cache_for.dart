import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

extension RefCacheFor on Ref {
  /// Keeps an `autoDispose` provider alive for [duration] after it is built,
  /// then lets it dispose. Mirrors the RN query client's `staleTime`.
  void cacheFor(Duration duration) {
    final link = keepAlive();
    final timer = Timer(duration, link.close);
    onDispose(timer.cancel);
  }
}
