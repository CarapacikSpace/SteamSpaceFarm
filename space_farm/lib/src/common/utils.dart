import 'dart:io';

class Utils {
  static Future<String> getCPUArchitecture() async {
    String? cpu;
    if (Platform.isWindows) {
      cpu = Platform.environment['PROCESSOR_ARCHITECTURE'];
    } else {
      final info = await Process.run('uname', ['-m']);
      cpu = info.stdout.toString().trim();
    }
    final cpuLower = cpu?.toLowerCase();

    return switch (cpuLower) {
      'x86_64' || 'x64' || 'amd64' => 'x64',
      'arm64' || 'aarch64' || 'armv8' => 'arm64',
      _ => throw Exception('Unsupported architecture: $cpuLower'),
    };
  }
}
