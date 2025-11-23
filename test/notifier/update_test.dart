import "dart:async";

import "package:riverpod/riverpod.dart";
import "package:riverpod_swiss_knife/src/notifier/update.dart";
import "package:test/test.dart";

void main() {
  group("UpdateNotifierMixin", () {
    late ProviderContainer container;
    final provider = NotifierProvider<CounterNotifier, int>(
      CounterNotifier.new,
    );

    setUp(() {
      container = ProviderContainer.test();
    });

    test("synchronously updates state using previous", () {
      container.listen(provider, (_, _) {});
      expect(container.read(provider), isZero);

      final result = container.read(provider.notifier).increment();

      expect(container.read(provider), equals(1));
      expect(result, equals(1));
    });
  });
}

class CounterNotifier extends Notifier<int> with UpdateNotifierMixin<int> {
  @override
  int build() {
    return 0;
  }

  FutureOr<int> increment() {
    return update((previousState) {
      return previousState + 1;
    });
  }
}
