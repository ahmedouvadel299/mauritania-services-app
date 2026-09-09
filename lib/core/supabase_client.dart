import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppSupabase {
  static late String debugUrl;
  static late String debugKeyLength;

  static Future<void> init() async {
    await dotenv.load(fileName: '.env');
    final url = dotenv.env['SUPABASE_URL'] ?? 'MISSING';
    final key = dotenv.env['SUPABASE_ANON_KEY'] ?? 'MISSING';
    debugUrl = url;
    debugKeyLength = 'طول المفتاح: ${key.length} حرف، أول 15 حرف: ${key.substring(0, key.length > 15 ? 15 : key.length)}';

    await Supabase.initialize(
      url: url.trim(),
      anonKey: key.trim(),
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
