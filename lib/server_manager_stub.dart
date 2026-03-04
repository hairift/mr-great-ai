// Stub implementation for web platform (dart:io not available).
// All methods are no-ops on web — server must be started manually.

class ServerManager {
  static Future<void> startServer() async {
    // No-op on web — server must already be running
  }

  static void stopServer() {
    // No-op on web
  }
}
