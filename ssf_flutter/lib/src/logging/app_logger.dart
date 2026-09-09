import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

abstract final class AppLogger() {
  static void info(String message, {String name = 'App'}) {
    if (kDebugMode) {
      developer.log(message, name: 'SSF.$name', level: 800);
    }
  }

  static void error(String message, Object error, StackTrace stackTrace, {String name = 'App'}) {
    if (kDebugMode) {
      developer.log('$message (${error.runtimeType})', name: 'SSF.$name', level: 1000, stackTrace: stackTrace);
    }
  }
}
