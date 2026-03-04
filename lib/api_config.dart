// Shared API configuration for all chat pages.
//
// The app auto-detects the correct URL per platform:
// - Web/Desktop: localhost (same machine)
// - Android/iOS: your PC's local IP (same WiFi network)
// - Public: ngrok or production URL

import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  // =================== SERVER URL CONFIG ===================
  // Your PC's local IP address (found via ipconfig)
  // HP dan PC harus di WiFi yang SAMA
  static const String _localNetworkIp = "192.168.1.7";

  // Untuk akses publik dari luar WiFi (uncomment & isi URL ngrok):
  // static const String _publicUrl = "https://your-id.ngrok-free.app";
  // ==========================================================

  /// Base URL — auto-selects per platform
  static String get baseUrl {
    // Uncomment line di bawah kalau pakai ngrok/public:
    // return _publicUrl;

    if (kIsWeb) {
      // Web browser di PC yang sama
      return "http://localhost:8000";
    }

    // Mobile (Android/iOS) — connect ke PC via WiFi
    return "http://$_localNetworkIp:8000";
  }

  /// API key for authentication
  static const String apiKey = "mrgreat-ucic-2024-secret-key";

  /// Endpoints
  static String get chatGeneralUrl => "$baseUrl/api/chat/general";
  static String get chatRagUrl => "$baseUrl/api/chat";
  static String get ragSearchUrl => "$baseUrl/api/rag/search";
  static String get healthUrl => "$baseUrl/api/health";

  /// Common headers with API key
  static Map<String, String> get headers => {
        'Content-Type': 'application/json',
        'X-API-Key': apiKey,
      };
}
