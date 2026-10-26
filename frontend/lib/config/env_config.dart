import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static String get baseUrl {
    final url = dotenv.env['BASE_URL'];
    if (url == null || url.trim().isEmpty) {
      return 'http://10.0.2.2:3000/api';
    }
    return url.trim();
  }
}
