import "dart:async";

import "package:meta/meta.dart";
import "package:riverpod/riverpod.dart";

/// A mixin that adds an `update` method,
/// meant to be used on [Notifier]
mixin UpdateNotifierMixin<T> on AnyNotifier<T, T> {
  /// A function to update [state] from its previous value.
  /// It's similar to [AsyncNotifier.update], but for [Notifier].
  ///
  /// The key difference is that, since a [Notifier] is synchronous,
  /// this function can't really throw because of previous state being invalid.
  ///
  /// If `cb` throws, the exception will be propagated,
  /// and [state] will not be modified.
  @visibleForTesting
  @protected
  FutureOr<T> update(FutureOr<T> Function(T previousState) cb) {
    final result = cb(state);
    if (result is Future<T>) {
      return result.then((result) {
        return state = result;
      });
    } else {
      return state = result;
    }
  }
}
