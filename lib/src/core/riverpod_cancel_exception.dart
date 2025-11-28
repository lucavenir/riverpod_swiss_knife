/// {@template riverpod_cancel_exception}
/// thrown when an operation is canceled:
/// should be quite low in your logs level,
/// and should be ignored in your business logic
/// {@endtemplate}
class RiverpodCancelException implements Exception {
  /// {@macro riverpod_cancel_exception}
  const RiverpodCancelException();
}
