import "package:fake_async/fake_async.dart";
import "package:riverpod/riverpod.dart";
import "package:riverpod_swiss_knife/src/ref/periodically_invalidate.dart";
import "package:riverpod_swiss_knife/src/ref/timeout.dart";
import "package:test/test.dart";
import "package:time/time.dart";

void main() {
  group("PeriodicallyInvalidateRef", () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer.test();
    });

    test("invalidates a provider periodically at specified interval", () {
      fakeAsync((async) {
        var count = 0;
        final target = Provider.autoDispose((ref) {
          return ++count;
        });

        final watcher = Provider.autoDispose((ref) {
          ref.periodicallyInvalidate(target, every: 2.minutes);
          return "watcher";
        });

        container.listen(watcher, (_, _) {});

        expect(container.read(target), equals(1));

        async.elapse(2.minutes);
        expect(container.read(target), equals(2));

        async.elapse(2.minutes);
        container.read(target);
        async.elapse(2.minutes);
        container.read(target);

        async.elapse(2.minutes);
        expect(container.read(target), equals(5));
      });
    });
    test("cancels timer when watcher provider is disposed", () {
      fakeAsync((async) {
        var count = 0;
        final target = Provider.autoDispose((ref) {
          return ++count;
        });

        final watcher = Provider.autoDispose((ref) {
          ref.periodicallyInvalidate(target, every: 2.minutes);
          return "watcher";
        });

        final watcherReader = container.listen(watcher, (_, _) {});
        final targetReader = container.listen(target, (_, _) {});

        expect(targetReader.read(), 1);
        async.elapse(2.minutes);
        expect(targetReader.read(), 2);

        watcherReader.close();

        async.elapse(2.hours);
        expect(targetReader.read(), 2);
      });
    });
    test("can exploit timer returned by periodicallyInvalidate", () {
      fakeAsync((async) {
        var count = 0;
        final target = Provider.autoDispose((ref) {
          return ++count;
        });

        final watcher = Provider.autoDispose((ref) {
          final timer = ref.periodicallyInvalidate(
            target,
            every: 2.minutes,
          );
          ref.timeout(timer.cancel, after: 2.hours);
          return "watcher";
        });

        container.listen(watcher, (_, _) {});
        final reader = container.listen(target, (_, _) {});

        expect(reader.read(), 1);
        async.elapse(2.minutes);
        expect(reader.read(), 2);

        async.elapse(2.minutes);
        expect(reader.read(), 3);

        async.elapse(2.hours);
        expect(reader.read(), 61);

        async.elapse(2.hours);
        expect(reader.read(), 61);
      });
    });
    test("does not invalidate target if watcher is never listened to", () {
      fakeAsync((async) {
        var count = 0;
        final target = Provider.autoDispose((ref) {
          return count++;
        });

        Provider.autoDispose((ref) {
          ref.periodicallyInvalidate(target, every: 100.milliseconds);
          return "watcher";
        });

        final reader = container.listen(target, (_, _) {});

        expect(reader.read(), isZero);
        async.elapse(2.hours);
        expect(reader.read(), isZero);
      });
    });
  });
}
