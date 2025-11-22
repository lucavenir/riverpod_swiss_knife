import "dart:async";

typedef VoidCallback = void Function();
typedef ValueSetter<T> = void Function(T value);
typedef ValueGetter<T> = T Function();

typedef FutureVoidCallback = Future<void> Function();
typedef FutureValueGetter<T> = Future<T> Function();
typedef FutureValueSetter<T> = Future<void> Function(T value);

typedef FutureOrVoidCallback = FutureOr<void> Function();
typedef FutureOrValueGetter<T> = FutureOr<T> Function();
typedef FutureOrValueSetter<T> = FutureOr<void> Function(T value);

typedef Fn<In, Out> = Out Function(In input);
