class SerialTaskQueue() {
  Future<void> _tail = Future<void>.value();

  Future<T> run<T>(Future<T> Function() operation) {
    final Future<T> result = _tail.then((_) => operation());
    _tail = result.then<void>((_) {}, onError: (Object error, StackTrace stack) {});
    return result;
  }
}
