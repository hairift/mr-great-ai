// Native (desktop/mobile) implementation — auto-starts Python server.

import 'dart:io';
import 'package:flutter/foundation.dart';

class ServerManager {
  static Process? _serverProcess;
  static bool _isStarted = false;

  /// Start the Python backend server automatically.
  /// Works on Windows, macOS, Linux. Skips on mobile (no Python available).
  static Future<void> startServer() async {
    if (_isStarted) return;

    try {
      final serverDir = _findServerDir();
      if (serverDir == null) {
        debugPrint('[ServerManager] Server directory not found — skipping auto-start');
        return;
      }

      final pythonExe = await _findPython(serverDir);
      if (pythonExe == null) {
        debugPrint('[ServerManager] Python not found — skipping auto-start');
        return;
      }

      debugPrint('[ServerManager] Starting: $pythonExe main.py in $serverDir');

      _serverProcess = await Process.start(
        pythonExe,
        ['main.py'],
        workingDirectory: serverDir,
        mode: ProcessStartMode.detachedWithStdio,
      );

      _isStarted = true;
      debugPrint('[ServerManager] ✅ Server started (PID: ${_serverProcess!.pid})');

      // Read server output in background for debugging
      _serverProcess!.stdout.listen((data) {
        debugPrint('[Server] ${String.fromCharCodes(data).trim()}');
      });
      _serverProcess!.stderr.listen((data) {
        debugPrint('[Server ERR] ${String.fromCharCodes(data).trim()}');
      });

      // Wait for server to initialize
      await Future.delayed(const Duration(seconds: 3));
    } catch (e) {
      debugPrint('[ServerManager] ❌ Failed to start: $e');
    }
  }

  /// Stop the Python backend server.
  static void stopServer() {
    if (_serverProcess != null) {
      debugPrint('[ServerManager] Stopping server (PID: ${_serverProcess!.pid})');
      _serverProcess!.kill();
      _serverProcess = null;
      _isStarted = false;
    }
  }

  /// Find server directory by checking common relative and absolute paths.
  static String? _findServerDir() {
    final candidates = [
      'server',
      '../server',
      '../../server',
      // Fallback absolute path
      'C:/Users/riana/mr_great_ai/server',
    ];

    for (final path in candidates) {
      try {
        final dir = Directory(path);
        if (dir.existsSync()) {
          final mainPy = File('$path/main.py');
          if (mainPy.existsSync()) {
            return dir.absolute.path;
          }
        }
      } catch (_) {}
    }
    return null;
  }

  /// Find Python — checks .venv first, then system Python.
  static Future<String?> _findPython(String serverDir) async {
    final venvPaths = [
      '$serverDir/../.venv/Scripts/python.exe', // Windows venv
      '$serverDir/../.venv/bin/python',          // macOS/Linux venv
      '$serverDir/venv/Scripts/python.exe',
      '$serverDir/venv/bin/python',
    ];

    for (final path in venvPaths) {
      try {
        if (File(path).existsSync()) {
          return File(path).absolute.path;
        }
      } catch (_) {}
    }

    // System Python fallback
    for (final cmd in ['python', 'python3']) {
      try {
        final result = await Process.run(cmd, ['--version']);
        if (result.exitCode == 0) return cmd;
      } catch (_) {}
    }

    return null;
  }
}
