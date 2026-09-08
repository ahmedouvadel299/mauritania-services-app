import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/supabase_client.dart';

/// نسخة مؤقتة تستخدم البريد الإلكتروني وكلمة المرور بدل OTP الهاتف،
/// لتفادي الحاجة لمزوّد SMS أثناء مرحلة البناء والاختبار.
/// عند الجاهزية لاحقًا لإعادة تفعيل الهاتف، تُستبدل هذه الدوال فقط
/// دون التأثير على أي كود آخر في التطبيق (بفضل فصل الطبقات).
class AuthService {
  final _client = AppSupabase.client;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) {
    return _client.auth.signUp(email: email, password: password);
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  /// يُستدعى بعد أول تسجيل ناجح لإنشاء صف في جدول users العام.
  Future<void> createUserProfile({
    required String fullName,
    required String role, // 'customer' | 'provider'
  }) async {
    final userId = _client.auth.currentUser!.id;
    final email = _client.auth.currentUser!.email!;
    await _client.from('users').upsert({
      'id': userId,
      'phone': email, // مؤقتًا نخزن البريد هنا إلى حين تفعيل الهاتف الحقيقي
      'full_name': fullName,
      'role': role,
    });
  }

  Future<void> signOut() => _client.auth.signOut();

  bool get isLoggedIn => _client.auth.currentUser != null;
}
