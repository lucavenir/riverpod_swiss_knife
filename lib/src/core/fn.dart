typedef VoidCallback = void Function();
typedef ValueSetter<T> = void Function(T value);
typedef ValueGetter<T> = T Function();

typedef AsyncValueGetter<T> = Future<T> Function();
typedef AsyncValueSetter<T> = Future<void> Function(T value);

typedef Fn<In, Out> = Out Function(In input);
