import "dart:async";

import "package:fake_async/fake_async.dart";
import "package:riverpod/riverpod.dart";
import "package:riverpod_swiss_knife/src/ref/on_repeat.dart";
import "package:test/test.dart";
import "package:time/time.dart";

void main() {
  group("RefOnRepeat", () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer.test();
    });

    test("executes callback periodically at specified interval", () {
      fakeAsync((async) {
        var counter = 0;
        final provider = Provider.autoDispose((ref) {
          ref.onRepeat((_) => counter++, every: 1.seconds);
          return "value";
        });

        container.listen(provider, (_, _) {});

        expect(counter, 0);
        async.elapse(1.seconds);
        expect(counter, 1);
        async.elapse(1.seconds);
        expect(counter, 2);
        async.elapse(3.seconds);
        expect(counter, 5);
      });
    });
    test("can exploit timer in the exposed callback", () {
      fakeAsync((async) {
        var counter = 0;
        final provider = Provider((ref) {
          ref.onRepeat(
            (timer) {
              counter++;
              if (counter > 2) {
                timer.cancel();
              }
            },
            every: 100.milliseconds,
          );
          return "value";
        });

        container.listen(provider, (_, _) {});

        async.elapse(100.milliseconds);
        expect(counter, 1);
        async.elapse(100.milliseconds);
        expect(counter, 2);
        async.elapse(2.hours);
        expect(counter, 3);
      });
    });
    test("cancels timer when provider is disposed", () {
      fakeAsync((async) {
        var callCount = 0;
        final provider = Provider((ref) {
          ref.onRepeat(
            (_) => callCount++,
            every: 1.seconds,
          );
          return "value";
        });

        container.listen(provider, (_, _) {});

        async.elapse(2.seconds);
        expect(callCount, 2);

        container.dispose();

        async.elapse(2.hours);
        expect(callCount, 2);
      });
    });
    test("can exploit timer returned by onRepeat", () {
      fakeAsync((async) {
        var counter = 0;
        final provider = StreamProvider.autoDispose((ref) {
          final timer = ref.onRepeat(
            (_) => counter++,
            every: 500.milliseconds,
          );
          return Stream.periodic(500.milliseconds, (count) {
            if (count > 2) {
              timer.cancel();
            }
            return count;
          });
        });

        final reader = container.listen(provider, (_, _) {});
        var read = reader.read();
        expect(counter, equals(0));
        expect(read, equals(const AsyncLoading<int>()));

        async.elapse(500.milliseconds);
        read = reader.read();
        expect(counter, equals(1));
        expect(read, equals(const AsyncData(0)));

        async.elapse(500.milliseconds);
        read = reader.read();
        expect(counter, equals(2));
        expect(read, equals(const AsyncData(1)));

        async.elapse(500.milliseconds);
        read = reader.read();
        expect(counter, equals(3));
        expect(read, equals(const AsyncData(2)));

        async.elapse(500.milliseconds);
        read = reader.read();
        expect(counter, equals(4));
        expect(read, equals(const AsyncData(3)));

        async.elapse(2.hours);
        expect(counter, equals(4));
      });
    });
    test("multiple providers should have independent timers", () {
      fakeAsync((async) {
        var count1 = 0;
        final provider1 = Provider.autoDispose((ref) {
          ref.onRepeat(
            (_) => count1++,
            every: 1.seconds,
          );
          return "1";
        });
        var count2 = 0;
        final provider2 = Provider.autoDispose((ref) {
          ref.onRepeat(
            (_) => count2++,
            every: 500.milliseconds,
          );
          return "2";
        });

        container.listen(provider1, (_, _) {});
        container.listen(provider2, (_, _) {});

        async.elapse(2.seconds);

        expect(count1, 2);
        expect(count2, 4);
      });
    });
  });
}
