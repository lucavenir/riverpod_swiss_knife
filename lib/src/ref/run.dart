import "package:riverpod/misc.dart";
import "package:riverpod/riverpod.dart";

/// Extension on [Ref] to run an asynchronous provider, and get its value.
extension RefRun on Ref {
  /// Runs the given asynchronous [provider], and returns its value.
  ///
  /// This method keeps alive the given [provider] while it's being listened to,
  /// fetches its computed value and closes the listener afterwards.
  ///
  /// This method is useful to execute an asynchronous provider from
  /// other providers, without adding a reactive dependency to it.
  ///
  /// WARNING: don't abuse of this method, meaning: don't violate the
  /// "one-way data flow" principle that riverpod is based on.
  ///
  /// Good usage example:
  /// ```dart
  /// final catsProvider = FutureProvider<List<Cat>>((ref) async {
  ///   // network delay mock
  ///   await Future.delayed(Duration(seconds: 1));
  ///   final fetched = [Cat(name: 'Whiskers'), Cat(name: 'Fluffy')];
  ///   // store the fetched cats in a global cache, database, etc.
  ///   return fetched;
  /// });
  ///
  /// final veterinarianProvider = Provider<Veterinarian>((ref) async {
  ///   // prefetch cats, so that they'll be offline cached as well,
  ///   // BUT, we don't depend on them:
  ///   // we just want to trigger the fetch and store.
  ///   unawaited(ref.run(catsProvider));
  ///   return Veterinarian(name: 'Dr. Smith');
  /// });
  /// ```
  ///
  /// Bad usage example:
  /// ```dart
  /// final someProvider = FutureProvider<int>((ref) async {
  ///   final value = await ref.run(otherProvider);
  ///   // ❌ Don't do this
  ///   // what you really want is to depend on otherProvider directly:
  ///   // final value = await ref.watch(otherProvider.future);
  ///   return value * 2;
  /// });
  /// ```
  Future<T> run<T>(AsyncProviderListenable<T> provider) async {
    final reader = listen(provider.future, (_, _) {});

    try {
      final result = await reader.read();
      return result;
    } finally {
      reader.close();
    }
  }
}
