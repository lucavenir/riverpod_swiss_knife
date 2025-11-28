import "dart:async";

import "package:riverpod/riverpod.dart";

import "../core/riverpod_cancel_exception.dart";

/// Extension on [Ref] to debounce the provider for a specific duration.
extension DebounceForRef on Ref {
  /// Waits for the specified [duration];
  /// then, if the provider disposes before the delay elapses,
  /// this method will throw a [RiverpodCancelException].
  ///
  /// This utility is meant to be awaited inside asynchronous providers to
  /// debounce any kind of asynchronous operation (e.g., network requests, heavy
  /// computations, etc.).
  ///
  /// See also:
  ///   - [How to debounce/cancel network requests](https://riverpod.dev/docs/how_to/cancel)
  ///   - [RiverpodCancelException]
  Future<void> debounceFor(Duration duration) async {
    await Future<void>.delayed(duration, () {});
    if (mounted) return;
    throw const RiverpodCancelException();
  }
}
