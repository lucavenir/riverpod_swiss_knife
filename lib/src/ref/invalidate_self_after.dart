import "dart:async";

import "package:riverpod/riverpod.dart";

import "timeout.dart";

extension RefInvalidateSelfAfter on Ref {
  Timer invalidateSelfAfter(Duration after) {
    return timeout(after, onTimeout: invalidateSelf);
  }
}
