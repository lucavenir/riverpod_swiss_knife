/// @docImport 'cache_for.dart';
library;

import "dart:async";

import "package:riverpod/riverpod.dart";

/// Extension on [Ref] to add a dispose delay.
extension AddDisposeDelayRef on Ref {
  /// Adds a delay before disposing the provider when all listeners are removed.
  ///
  /// This results in the provider being kept alive for at least the specified
  /// [delay] duration after the last listener is removed.
  ///
  /// See also:
  ///   - [CacheRef.cacheFor] to cache the provider for a specific duration,
  ///   instead of delaying the disposal.
  ///   - [Ref.keepAlive] to keep the provider alive, possibly indefinitely,
  ///   or if you want to manage the disposal manually.
  void addDisposeDelay(Duration delay) {
    final link = keepAlive();

    Timer? timer;

    onCancel(() {
      timer = Timer(delay, link.close);
    });
    onResume(() {
      timer?.cancel();
    });
    onDispose(() {
      timer?.cancel();
    });
  }
}
