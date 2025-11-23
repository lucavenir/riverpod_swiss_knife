import "dart:async";

import "package:fake_async/fake_async.dart";
import "package:riverpod/riverpod.dart";
import "package:riverpod_swiss_knife/src/core/riverpod_cancel_exception.dart";
import "package:riverpod_swiss_knife/src/ref/run.dart";
import "package:test/test.dart";
import "package:time/time.dart";

void main() {
  group("RefRun", () {
    late ProviderContainer container;

    final asyncProvider = FutureProvider.autoDispose((ref) async {
      await Future<void>.delayed(2.minutes);
      if (!ref.mounted) throw const RiverpodCancelException();
      return 42069;
    });

    final provider = Provider.autoDispose((ref) {
      ref.run(asyncProvider).ignore();
      return 99;
    });

    setUp(() {
      container = ProviderContainer.test();
    });

    test("keeps target alive as it executes, while caller's alive", () async {
      fakeAsync((async) {
        final reader = container.listen(provider, (_, _) {});

        expect(reader.read(), 99);
        expect(container.exists(asyncProvider), isTrue);

        async.elapse(1.minutes);
        expect(container.exists(asyncProvider), isTrue);

        async.elapse(1.minutes);
        expect(container.exists(asyncProvider), isFalse);
      });
    });

    test("if the caller disposes, run closes its link as well", () {
      fakeAsync((async) {
        final reader = container.listen(provider, (_, _) {});
        final future = container.read(asyncProvider.future);

        expect(reader.read(), 99);
        expect(container.exists(asyncProvider), isTrue);

        reader.close();
        async.flushTimers();

        expect(container.exists(provider), isFalse);
        expect(container.exists(asyncProvider), isFalse);

        expect(future, throwsA(isA<RiverpodCancelException>()));
        async.flushMicrotasks();
      });
    });
  });
}
