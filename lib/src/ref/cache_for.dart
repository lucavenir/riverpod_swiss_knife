import "dart:async";

import "package:riverpod/riverpod.dart";

import "timeout.dart";

extension CacheRef on Ref {
  Timer cacheFor(Duration duration) {
    final link = keepAlive();
    final timer = timeout(link.close, after: duration);
    return timer;
  }
}
