import "dart:async";

import "package:meta/meta.dart";
import "package:riverpod/riverpod.dart";

mixin UpdateNotifierMixin<T> on AnyNotifier<T, T> {
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
