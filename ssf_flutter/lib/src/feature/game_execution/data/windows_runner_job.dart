import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:ssf_flutter/src/feature/game_execution/data/game_runner_connection.dart';

final class WindowsRunnerJob(String name) {
  this {
    final Pointer<Utf16> nativeName = name.toNativeUtf16();
    try {
      _handle = _create(nullptr, nativeName);
      final int error = _lastError();
      if (_handle == nullptr) {
        throw const GameRunnerException('job_setup_failed');
      }
      if (error == 183) {
        close();
        throw const GameRunnerException('job_setup_failed');
      }
    } finally {
      calloc.free(nativeName);
    }
  }

  static final _kernel = DynamicLibrary.open('kernel32.dll');
  static final Pointer<Void> Function(Pointer<Void>, Pointer<Utf16>) _create = _kernel
      .lookupFunction<
        Pointer<Void> Function(Pointer<Void>, Pointer<Utf16>),
        Pointer<Void> Function(Pointer<Void>, Pointer<Utf16>)
      >('CreateJobObjectW');
  static final int Function(Pointer<Void>) _close = _kernel
      .lookupFunction<Int32 Function(Pointer<Void>), int Function(Pointer<Void>)>('CloseHandle');
  static final int Function() _lastError = _kernel.lookupFunction<Uint32 Function(), int Function()>('GetLastError');
  Pointer<Void> _handle = nullptr;

  void close() {
    if (_handle != nullptr) {
      _close(_handle);
      _handle = nullptr;
    }
  }
}
