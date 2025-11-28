/// @docImport 'add_dispose_delay.dart';
library;

import "dart:async";

import "package:riverpod/riverpod.dart";

import "timeout.dart";

/// Extension on [Ref] to cache the provider for a specific duration.
extension CacheRef on Ref {
  /// Caches the provider for the specified [duration].
  ///
  /// This results in the provider being kept alive *from the time this method is
  /// called* for at least the specified [duration], even if all listeners are
  /// removed.
  ///
  /// See also:
  ///   - [AddDisposeDelayRef.addDisposeDelay] to cache the provider for a
  ///   specific duration *after* the last listener is removed.
  ///   - [Ref.keepAlive] to keep the provider alive, possibly indefinitely,
  ///   or if you want to manage the disposal manually.
  Timer cacheFor(Duration duration) {
    final link = keepAlive();
    final timer = timeout(link.close, after: duration);
    return timer;
  }
}
