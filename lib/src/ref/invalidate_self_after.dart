import "dart:async";

import "package:riverpod/riverpod.dart";

import "timeout.dart";

/// Extension on [Ref] to invalidate itself after a specific duration.
extension RefInvalidateSelfAfter on Ref {
  /// Invalidates the provider after the specified duration.
  ///
  /// The invalidation is canceled if this disposes before the delay elapses.
  ///
  /// Returns the [Timer] used to schedule the invalidation, which can be
  /// used to manually (and prematurely) cancel the invalidation if needed.
  ///
  /// NOTE.
  /// used as-is, this method will likely cause the provider
  /// to self invalidate periodically;
  /// if that's not what you want, consider using this method in combination
  /// with some conditional logic.
  ///
  /// See also:
  ///   - [RefTimeout.timeout]
  ///   - [Ref.invalidateSelf]
  ///   - [Timer]
  Timer invalidateSelfAfter(Duration after) {
    return timeout(invalidateSelf, after: after);
  }
}
