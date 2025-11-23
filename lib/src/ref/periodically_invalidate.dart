import "dart:async";

import "package:riverpod/misc.dart";
import "package:riverpod/riverpod.dart";

import "on_repeat.dart";

extension PeriodicallyInvalidateRef on Ref {
  Timer periodicallyInvalidate<T>(
    ProviderBase<T> provider, {
    required Duration every,
  }) {
    return onRepeat((value) {
      invalidate(provider);
    }, every: every);
  }
}
