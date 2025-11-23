import "dart:async";

import "package:riverpod/riverpod.dart";

extension AddDisposeDelayRef on Ref {
  void addDisposeDelay(Duration delay) {
    final link = keepAlive();

    Timer? timer;

    onCancel(() {
      timer = Timer(delay, link.close);
    });
    onResume(() {
      timer?.cancel();
    });
    onDispose(() {
      timer?.cancel();
    });
  }
}
