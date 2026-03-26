// Shared API configuration for all chat pages.
//
// Server is deployed to HuggingFace Spaces — always online 24/7!

class ApiConfig {
  // =================== SERVER URL ===================
  // HuggingFace Spaces (cloud, 24/7, gratis!)
  static const String _cloudUrl = "https://firaarifaja-mrgreat-ai.hf.space";

  // Local development (uncomment untuk dev lokal)
  // static const String _localUrl = "http://localhost:8000";
  // ==================================================

  /// Base URL — pakai cloud URL supaya bisa diakses dari mana saja
  static String get baseUrl {
    // Untuk development lokal, uncomment baris di bawah:
    // if (kIsWeb) return "http://localhost:8000";
    // return "http://10.0.2.2:8000";

    return _cloudUrl;
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
