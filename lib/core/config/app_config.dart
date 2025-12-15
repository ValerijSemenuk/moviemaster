import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get tmdbApiKey => dotenv.env['TMDB_API_KEY'] ?? '';
  static String get tmdbBaseUrl => dotenv.env['TMDB_BASE_URL'] ?? '';

  static void load() {
  }
}