import 'dart:async';
import 'dart:math';

class ProcessActionQueue({Duration Function()? nextDelay, Future<void> Function(Duration)? wait}) {
  final Duration Function() _nextDelay = nextDelay ?? _randomDelay;
  final Future<void> Function(Duration) _wait = wait ?? Future<void>.delayed;
  final Stopwatch _clock = Stopwatch()..start();
  Future<void> _tail = Future<void>.value();
  Duration _readyAt = Duration.zero;
  int _generation = 0;
  Completer<void> _cancelled = Completer<void>();
  static final _random = Random();

  static Duration _randomDelay() => Duration(milliseconds: 300 + _random.nextInt(201));

  Future<void> run(Future<void> Function() action, {bool Function()? shouldRun}) {
    final int generation = _generation;
    final Future<void> cancelled = _cancelled.future;
    final Future<void> operation = _tail.then((_) async {
      if (generation != _generation || (shouldRun != null && !shouldRun())) {
        return;
      }
      final Duration remaining = _readyAt - _clock.elapsed;
      if (remaining > Duration.zero) {
        await Future.any([_wait(remaining), cancelled]);
      }
      if (generation != _generation || (shouldRun != null && !shouldRun())) {
        return;
      }
      try {
        await action();
      } finally {
        _readyAt = _clock.elapsed + _nextDelay();
      }
    });
    _tail = operation.catchError((Object _) {});
    return operation;
  }

  void cancelPending() {
    _generation++;
    _cancelled.complete();
    _cancelled = Completer<void>();
    _readyAt = Duration.zero;
  }
}
