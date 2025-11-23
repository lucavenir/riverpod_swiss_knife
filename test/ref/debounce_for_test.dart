import "package:fake_async/fake_async.dart";
import "package:riverpod/riverpod.dart";
import "package:riverpod_swiss_knife/src/core/riverpod_cancel_exception.dart";
import "package:riverpod_swiss_knife/src/ref/debounce_for.dart";
import "package:test/test.dart";
import "package:time/time.dart";

void main() {
  group("DebounceForRef", () {
    late ProviderContainer container;
    final provider = FutureProvider.autoDispose<int>((ref) async {
      await ref.debounceFor(600.milliseconds);
      return 42069;
    });

    setUp(() {
      container = ProviderContainer.test();
    });

    test("debounces a provider, inherently introducing a delay", () {
      fakeAsync((async) {
        final sub = container.listen(provider, (_, _) {});

        async.elapse(600.milliseconds);

        expect(sub.read(), equals(const AsyncData<int>(42069)));
        async.elapse(2.hours);
        expect(sub.read(), equals(const AsyncData<int>(42069)));
      });
    });
    test("if disposed before the debounce, will throw a cancel exception", () {
      fakeAsync((async) {
        final sub = container.listen(provider, (_, _) {});
        final future = container.read(provider.future);

        async.elapse(200.milliseconds);
        sub.close();
        async.elapse(400.milliseconds);

        expect(future, throwsA(isA<RiverpodCancelException>()));
        async.flushMicrotasks();
      });
    });
  });
}
