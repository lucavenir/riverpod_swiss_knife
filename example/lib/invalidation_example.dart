/// these examples showcase various invalidation techniques
/// and also some footguns to be aware of.
///
/// cache invalidation is hard!
library;

import 'package:riverpod/riverpod.dart';
import 'package:riverpod_swiss_knife/riverpod_swiss_knife.dart';
import 'package:time/time.dart';

final myProvider = FutureProvider.autoDispose<int>((ref) async {
  await Future.delayed(800.milliseconds);

  // the following self-invalidates `myProvider` *every* 5 minutes
  ref.invalidateSelfAfter(5.minutes);
  return 420;
});

final anotherProvider = FutureProvider.autoDispose<int>((ref) async {
  final result = await ref.watch(myProvider.future);

  // because `myProvider` invalidates itself every 5 minutes,
  // `anotherProvider` will also be invalidated every 5 minutes.

  return result * 2;
});

final yetAnotherProvider = FutureProvider.autoDispose<int>((ref) async {
  await Future.delayed(800.milliseconds);

  // invalidate `anotherProvider`, after 3 minutes
  ref.timeout(() {
    ref.invalidate(anotherProvider);
  }, after: 3.minutes);

  return 69;
});

final yeetProvider = FutureProvider.autoDispose<int>((ref) async {
  final result = await ref.watch(yetAnotherProvider.future);

  // periodically invalidate `anotherProvider` every 2 minutes
  // careful! because of the chosen timings,
  // `yetAnotherProvider`'s `timeout` will be effectively ignored
  ref.invalidatePeriodically(yetAnotherProvider, every: 2.minutes);

  return result * 3;
});
