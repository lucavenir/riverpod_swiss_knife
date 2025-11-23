import "package:fake_async/fake_async.dart";
import "package:riverpod/riverpod.dart";
import "package:riverpod_swiss_knife/src/ref/invalidate_self_after.dart";
import "package:test/test.dart";
import "package:time/time.dart";

void main() {
  group("RefInvalidateSelfAfter", () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer.test();
    });

    test("cyclically invalidates provider after specified duration", () {
      fakeAsync((async) {
        var count = 0;
        final provider = FutureProvider.autoDispose((ref) async {
          ref.invalidateSelfAfter(1.seconds);
          return count++;
        });

        final reader = container.listen(provider, (_, _) {});

        expect(count, 1);
        expect(reader.read(), equals(const AsyncLoading<int>()));

        async.elapse(Duration.zero);

        expect(count, 1);
        expect(reader.read(), equals(const AsyncData<int>(0)));

        async.elapse(1.seconds);

        expect(count, 2);
        expect(reader.read(), equals(const AsyncData<int>(1)));

        async.elapse(2.minutes);
        expect(count, 122);
        expect(reader.read(), equals(const AsyncData<int>(121)));
      });
    });
    test("stops invalidating when provider is disposed", () {
      fakeAsync((async) {
        var count = 0;
        final provider = Provider.autoDispose((ref) {
          count++;
          ref.invalidateSelfAfter(1.seconds);
          return "value";
        });

        container.listen(provider, (_, _) {});

        expect(count, 1);
        async.elapse(2.seconds);
        expect(count, 3);

        container.dispose();

        async.elapse(2.hours);
        expect(count, 3);
      });
    });
    test("multiple providers have independent invalidation cycles", () {
      fakeAsync((async) {
        var count1 = 0;
        final provider1 = Provider.autoDispose((ref) {
          count1++;
          ref.invalidateSelfAfter(1.seconds);
          return "1";
        });

        var count2 = 0;
        final provider2 = Provider.autoDispose((ref) {
          count2++;
          ref.invalidateSelfAfter(500.milliseconds);
          return "2";
        });

        container.listen(provider1, (_, _) {});
        container.listen(provider2, (_, _) {});

        expect(count1, 1);
        expect(count2, 1);

        async.elapse(500.milliseconds);
        expect(count1, 1);
        expect(count2, 2);

        async.elapse(500.milliseconds);
        expect(count1, 2);
        expect(count2, 3);

        async.elapse(1.seconds);
        expect(count1, 3);
        expect(count2, 5);
      });
    });
    test("can be conditionally applied to stop invalidation cycle", () {
      fakeAsync((async) {
        var count = 0;
        final provider = Provider.autoDispose((ref) {
          count++;
          if (count < 4) {
            ref.invalidateSelfAfter(500.milliseconds);
          }
          return count;
        });

        container.listen(provider, (_, _) {});

        expect(count, 1);
        async.elapse(500.milliseconds);
        expect(count, 2);
        async.elapse(500.milliseconds);
        expect(count, 3);
        async.elapse(500.milliseconds);
        expect(count, 4);
        async.elapse(2.hours);
        expect(count, 4);
      });
    });
    test("can exploit timer to prematurely cancel invalidation", () {
      fakeAsync((async) {
        var count = 0;
        final provider = Provider.autoDispose((ref) {
          final timer = ref.invalidateSelfAfter(1.seconds);
          if (count > 2) {
            timer.cancel();
          }
          return count++;
        });

        final reader = container.listen(provider, (_, _) {});

        var read = reader.read();
        expect(count, equals(1));
        expect(read, equals(0));

        async.elapse(1.seconds);

        expect(count, equals(2));
        read = reader.read();
        expect(read, equals(1));

        async.elapse(1.seconds);

        expect(count, equals(3));
        read = reader.read();
        expect(read, equals(2));

        async.elapse(1.seconds);

        expect(count, equals(4));
        read = reader.read();
        expect(read, equals(3));

        async.elapse(2.hours);

        expect(count, equals(4));
        read = reader.read();
        expect(read, equals(3));
      });
    });
  });
}
