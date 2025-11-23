import "package:riverpod/misc.dart";
import "package:riverpod/riverpod.dart";

extension RefRun on Ref {
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
