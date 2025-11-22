import "dart:async" show Timer;

import "package:riverpod/riverpod.dart";

import "../core/fn.dart";

extension RefOnRepeat on Ref {
  Timer onRepeat(ValueSetter<Timer> cb, {required Duration every}) {
    final timer = Timer.periodic(every, cb);
    onDispose(timer.cancel);
    return timer;
  }
}
