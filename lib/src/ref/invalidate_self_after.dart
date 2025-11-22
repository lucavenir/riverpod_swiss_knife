import "package:riverpod/riverpod.dart";

import "timeout.dart";

extension RefInvalidateSelfAfter on Ref {
  void invalidateSelfAfter(Duration after) {
    timeout(after, onTimeout: invalidateSelf);
  }
}
