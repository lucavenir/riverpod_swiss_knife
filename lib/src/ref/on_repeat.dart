/// @docImport 'invalidate_self_after.dart';
library;

import "dart:async" show Timer;

import "package:riverpod/riverpod.dart";

import "../core/fn.dart";

/// Extension on [Ref] to do something repeatedly at a specific interval.
extension RefOnRepeat on Ref {
  /// Calls the provided callback [cb] every [every] duration.
  ///
  /// The repeated calls are canceled when the provider is disposed.
  ///
  /// The returned [Timer] can be used to cancel the repeated calls manually
  /// if needed.
  ///
  /// Tip: don't use this to invalidate self repeatedly; instead, consider using
  /// `invalidateSelfAfter`, since a self invalidation will re-execute
  /// its logic anyways
  ///
  /// See also:
  ///   - [Timer.periodic]
  ///   - [RefInvalidateSelfAfter.invalidateSelfAfter]
  Timer onRepeat(ValueSetter<Timer> cb, {required Duration every}) {
    final timer = Timer.periodic(every, cb);
    onDispose(timer.cancel);
    return timer;
  }
}
