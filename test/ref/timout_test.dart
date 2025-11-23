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
            () => executed = true,
            after: 1.seconds,
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
            () => counter++,
            after: 500.milliseconds,
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
            () => executed = true,
            after: 1.seconds,
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
            () => executed = true,
            after: 2.seconds,
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
            () => executed1 = true,
            after: 1.seconds,
          );
          return "1";
        });

        var executed2 = false;
        final provider2 = Provider.autoDispose((ref) {
          ref.timeout(
            () => executed2 = true,
            after: 500.milliseconds,
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
            () async {
              await Future<void>.delayed(100.milliseconds);
              executed = true;
            },
            after: 1.seconds,
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
            () async {
              await Future<void>.delayed(Duration.zero, () {
                executed = true;
              });
            },
            after: Duration.zero,
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
            () => counter1++,
            after: 500.milliseconds,
          );
          ref.timeout(
            () => counter2++,
            after: 1.seconds,
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
