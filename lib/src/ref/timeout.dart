import "dart:async" show Timer;

import "package:riverpod/riverpod.dart";

import "../core/fn.dart";

extension RefTimeout on Ref {
  Timer timeout(
    FutureOrVoidCallback onTimeout, {
    required Duration after,
  }) {
    final timer = Timer(after, onTimeout);
    onDispose(timer.cancel);
    return timer;
  }
}
