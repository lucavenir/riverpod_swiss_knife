import "dart:async";

import "package:riverpod/riverpod.dart";

import "../core/riverpod_cancel_exception.dart";

extension DebounceForRef on Ref {
  Future<void> debounceFor(Duration duration) async {
    await Future<void>.delayed(duration, () {
      if (mounted) return;
      throw const RiverpodCancelException();
    });
  }
}
