/// these examples showcase various caching techniques
/// and also some side effects to be aware of.
///
/// cache invalidation is hard!
library;

import 'package:riverpod/riverpod.dart';
import 'package:time/time.dart';

final myProvider = FutureProvider.autoDispose<int>((ref) async {
  // if the provider is recreated within 600ms,
  // the ongoing computation will be cancelled
  ref.debounceFor(600.milliseconds);
  // emulate network delay
  await Future.delayed(800.milliseconds);
  ref.cacheFor(5.minutes);
  return 420;
});

final anotherProvider = FutureProvider.autoDispose<int>((ref) async {
  final result = await ref.watch(myProvider.future);

  // the following keeps this provider alive for at least 3 seconds after
  // its last listener cancels
  // careful! `myProvider` will be kept alive as well:
  // this can "override" the 5 minutes caching of `myProvider`.
  ref.addDisposeDelay(3.seconds);

  return result * 2;
});
