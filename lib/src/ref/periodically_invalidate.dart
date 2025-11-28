/// @docImport 'invalidate_self_after.dart';
library;

import "dart:async";

import "package:riverpod/misc.dart";
import "package:riverpod/riverpod.dart";

import "on_repeat.dart";

/// Extension on [Ref] to periodically invalidate a provider.
extension PeriodicallyInvalidateRef on Ref {
  /// Periodically invalidates the given [provider] every [every] duration.
  ///
  /// The periodic invalidation is canceled when the provider is disposed.
  ///
  /// The returned [Timer] can be used to cancel the periodic invalidation
  /// manually if needed.
  ///
  /// See also:
  ///   - [RefOnRepeat.onRepeat] to execute arbitrary code periodically.
  ///   - [RefInvalidateSelfAfter.invalidateSelfAfter] if you want to
  ///    periodically self-invalidate your provider
  Timer periodicallyInvalidate<T>(
    ProviderBase<T> provider, {
    required Duration every,
  }) {
    return onRepeat((value) {
      invalidate(provider);
    }, every: every);
  }
}
