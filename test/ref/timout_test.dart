import "dart:async";

import "package:fake_async/fake_async.dart";
import "package:riverpod/riverpod.dart";
import "package:riverpod_swiss_knife/src/ref/timeout.dart";
import "package:test/test.dart";
import "package:time/time.dart";

void main() {
  group("RefTimeout", () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer.test();
    });

    test("executes callback after specified duration", () {
      fakeAsync((async) {
        var executed = false;
        final provider = Provider.autoDispose((ref) {
          ref.timeout(
            1.seconds,
            onTimeout: () => executed = true,
          );
          return "value";
        });

        container.listen(provider, (_, _) {});

        expect(executed, isFalse);
        async.elapse(500.milliseconds);
        expect(executed, isFalse);
        async.elapse(500.milliseconds);
        expect(executed, isTrue);
      });
    });
    test("executes callback only once", () {
      fakeAsync((async) {
        var counter = 0;
        final provider = Provider.autoDispose((ref) {
          ref.timeout(
            500.milliseconds,
            onTimeout: () => counter++,
          );
          return "value";
        });

        container.listen(provider, (_, _) {});

        expect(counter, 0);
        async.elapse(500.milliseconds);
        expect(counter, 1);
        async.elapse(2.hours);
        expect(counter, 1);
      });
    });
    test("cancels timer when provider is disposed", () {
      fakeAsync((async) {
        var executed = false;
        final provider = Provider.autoDispose((ref) {
          ref.timeout(
            1.seconds,
            onTimeout: () => executed = true,
          );
          return "value";
        });

        container.listen(provider, (_, _) {});

        expect(executed, false);
        async.elapse(500.milliseconds);
        expect(executed, false);

        container.dispose();

        async.elapse(2.hours);
        expect(executed, false);
      });
    });
    test("can exploit timer returned by timeout", () {
      fakeAsync((async) {
        var executed = false;
        final provider = Provider.autoDispose((ref) {
          final timer = ref.timeout(
            2.seconds,
            onTimeout: () => executed = true,
          );
          Future<void>.delayed(500.milliseconds, timer.cancel);
          return "value";
        });

        container.listen(provider, (_, _) {});

        expect(executed, false);
        async.elapse(2.hours);
        expect(executed, false);
      });
    });
    test("multiple providers should have independent timers", () {
      fakeAsync((async) {
        var executed1 = false;
        final provider1 = Provider.autoDispose((ref) {
          ref.timeout(
            1.seconds,
            onTimeout: () => executed1 = true,
          );
          return "1";
        });

        var executed2 = false;
        final provider2 = Provider.autoDispose((ref) {
          ref.timeout(
            500.milliseconds,
            onTimeout: () => executed2 = true,
          );
          return "2";
        });

        container.listen(provider1, (_, _) {});
        container.listen(provider2, (_, _) {});

        expect(executed1, false);
        expect(executed2, false);

        async.elapse(500.milliseconds);
        expect(executed1, false);
        expect(executed2, true);

        async.elapse(500.milliseconds);
        expect(executed1, true);
        expect(executed2, true);
      });
    });
    test("supports async callbacks", () {
      fakeAsync((async) {
        var executed = false;
        final provider = Provider.autoDispose((ref) {
          ref.timeout(
            1.seconds,
            onTimeout: () async {
              await Future<void>.delayed(100.milliseconds);
              executed = true;
            },
          );
          return "value";
        });

        container.listen(provider, (_, _) {});

        expect(executed, false);
        async.elapse(1.seconds);
        expect(executed, false);
        async.elapse(100.milliseconds);
        expect(executed, true);
      });
    });
    test("works with zero duration", () {
      fakeAsync((async) {
        var executed = false;
        final provider = Provider.autoDispose((ref) {
          ref.timeout(
            Duration.zero,
            onTimeout: () async {
              await Future<void>.delayed(Duration.zero, () {
                executed = true;
              });
            },
          );
          return "value";
        });

        container.listen(provider, (_, _) {});

        expect(executed, isFalse);
        async.elapse(Duration.zero);
        expect(executed, isTrue);
      });
    });
    test("can be used multiple times in the same provider", () {
      fakeAsync((async) {
        var counter1 = 0;
        var counter2 = 0;
        final provider = Provider.autoDispose((ref) {
          ref.timeout(
            500.milliseconds,
            onTimeout: () => counter1++,
          );
          ref.timeout(
            1.seconds,
            onTimeout: () => counter2++,
          );
          return "value";
        });

        container.listen(provider, (_, _) {});

        expect(counter1, 0);
        expect(counter2, 0);

        async.elapse(500.milliseconds);
        expect(counter1, 1);
        expect(counter2, 0);

        async.elapse(500.milliseconds);
        expect(counter1, 1);
        expect(counter2, 1);
      });
    });
  });
}
