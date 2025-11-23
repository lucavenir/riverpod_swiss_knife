import "package:fake_async/fake_async.dart";
import "package:riverpod/riverpod.dart";
import "package:riverpod_swiss_knife/src/ref/cache_for.dart";
import "package:test/test.dart";
import "package:time/time.dart";

void main() {
  group("CacheForRef", () {
    late ProviderContainer container;
    final provider = Provider.autoDispose((ref) {
      ref.cacheFor(6.minutes);
      return 0;
    });

    setUp(() {
      container = ProviderContainer.test();
    });

    test("keeps the provider alive for the specified duration", () {
      fakeAsync((async) {
        final sub = container.listen(provider, (_, _) {});

        sub.close();

        expect(container.exists(provider), isTrue);
        async.elapse(4.minutes);
        expect(container.exists(provider), isTrue);
        async.elapse(2.minutes);
        expect(container.exists(provider), isFalse);
      });
    });
    test("cache time depends on invocation time", () {
      fakeAsync((async) {
        // Scenario 1: Cancel after 2 seconds
        // The provider should remain alive for 5 - 2 = 3 more seconds
        final sub = container.listen(provider, (_, _) {});

        async.elapse(2.minutes);
        sub.close();

        expect(container.exists(provider), isTrue);
        async.elapse(2.minutes);
        expect(container.exists(provider), isTrue);
        async.elapse(2.minutes);
        expect(container.exists(provider), isFalse);
      });
    });
    test("cache time, if elapsed while listening, won't count anymore", () {
      fakeAsync((async) {
        final sub = container.listen(provider, (_, _) {});

        async.elapse(6.minutes);
        sub.close();

        async.elapse(Duration.zero);
        expect(container.exists(provider), isFalse);
      });
    });
  });
}
