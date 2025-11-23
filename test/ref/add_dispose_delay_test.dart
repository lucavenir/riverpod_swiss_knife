import "package:fake_async/fake_async.dart";
import "package:riverpod/riverpod.dart";
import "package:riverpod_swiss_knife/src/ref/add_dispose_delay.dart";
import "package:test/test.dart";
import "package:time/time.dart";

void main() {
  group("AddDisposeDelayRef", () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer.test();
    });

    test("keeps the cache for a fixed time *after* a subscription cancel", () {
      fakeAsync((async) {
        final provider = Provider.autoDispose((ref) {
          ref.addDisposeDelay(5.minutes);
          return 0;
        });

        final sub = container.listen(provider, (_, _) {});

        async.elapse(2.hours);
        sub.close();

        expect(container.exists(provider), isTrue);
        async.elapse(3.minutes);
        expect(container.exists(provider), isTrue);
        async.elapse(2.minutes);
        expect(container.exists(provider), isFalse);
      });
    });
    test("cancelling and resuming resets the dispose delay", () {
      fakeAsync((async) {
        final provider = Provider.autoDispose((ref) {
          ref.addDisposeDelay(5.minutes);
          return 0;
        });

        var sub = container.listen(provider, (_, _) {});
        async.elapse(2.hours);
        sub.close();
        async.elapse(4.minutes);
        async.elapse(59.seconds);
        sub = container.listen(provider, (_, _) {});
        async.elapse(4.days);
        sub.close();

        async.elapse(4.minutes);
        async.elapse(58.seconds);
        expect(container.exists(provider), isTrue);
        async.elapse(2.seconds);
        expect(container.exists(provider), isFalse);
      });
    });
  });
}
