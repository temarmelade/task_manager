import 'package:flutter/foundation.dart';

class AppConfig {
  const AppConfig._();

  static const String _apiUrlOverride = String.fromEnvironment('API_URL');

  static String get baseUrl {
    if (_apiUrlOverride.isNotEmpty) return _apiUrlOverride;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000';
    }
    return 'http://localhost:3000';
  }
}
