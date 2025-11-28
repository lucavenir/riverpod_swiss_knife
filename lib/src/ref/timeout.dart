/// @docImport 'cache_for.dart';
/// @docImport 'invalidate_self_after.dart';
library;

import "dart:async" show Timer;

import "package:riverpod/riverpod.dart";

import "../core/fn.dart";

/// Extension on [Ref] to do something after a specific duration.
extension RefTimeout on Ref {
  /// Calls the provided callback [onTimeout] after [after] duration.
  ///
  /// The timeout is canceled when the provider is disposed.
  ///
  /// The returned [Timer] can be used to cancel the timeout manually if needed.
  ///
  /// See also:
  ///   - [RefInvalidateSelfAfter.invalidateSelfAfter] to see how this can be
  ///     used to self-invalidate a provider after a delay.
  ///   - [CacheRef.cacheFor] to see how this can be used to cache a provider's
  ///     value for a specific duration.
  ///   - [Timer]
  Timer timeout(
    FutureOrVoidCallback onTimeout, {
    required Duration after,
  }) {
    final timer = Timer(after, onTimeout);
    onDispose(timer.cancel);
    return timer;
  }
}
