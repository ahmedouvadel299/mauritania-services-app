import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// نقطة اتصال واحدة بـ Supabase لكل التطبيق.
/// المفاتيح تُقرأ من .env وليست مكتوبة هنا مباشرة (حماية أساسية للأسرار).
class AppSupabase {
  static Future<void> init() async {
    await dotenv.load(fileName: '.env');
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
