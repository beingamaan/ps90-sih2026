import 'package:flutter/foundation.dart';

/// Configuration manager for CraftBridge API endpoints.
/// Supports local development (default: http://127.0.0.1:8000)
/// and remote backend URLs specified via environment variables or runtime override.
class ApiConfig {
  static const String _defaultLocalUrl = 'http://127.0.0.1:8000';

  /// Compile-time environment variable: flutter run --dart-define=BACKEND_URL=https://my-backend.onrender.com
  static const String _envBackendUrl = String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: _defaultLocalUrl,
  );

  static String _customBaseUrl = '';

  /// Active base URL for backend API requests.
  static String get baseUrl {
    if (_customBaseUrl.isNotEmpty) {
      return _customBaseUrl;
    }
    return _envBackendUrl;
  }

  /// Sets a custom base URL dynamically at runtime (e.g., from settings or cluster config).
  static void setCustomBaseUrl(String url) {
    _customBaseUrl = url.trim().replaceAll(RegExp(r'/$'), '');
    if (kDebugMode) {
      print('ApiConfig: Updated custom base URL to: $_customBaseUrl');
    }
  }

  /// Resets to default environment base URL.
  static void resetBaseUrl() {
    _customBaseUrl = '';
  }
}
