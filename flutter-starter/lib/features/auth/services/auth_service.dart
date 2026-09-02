import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/supabase_client.dart';

/// كل منطق المصادقة في مكان واحد — الشاشات تستدعي هذه الدوال فقط
/// ولا تتحدث مع Supabase مباشرة (فصل الطبقات).
class AuthService {
  final _client = AppSupabase.client;

  /// يرسل رمز OTP إلى رقم الهاتف. الصيغة يجب أن تكون دولية: +2224xxxxxxx
  Future<void> sendOtp(String phone) async {
    await _client.auth.signInWithOtp(phone: phone);
  }

  /// يتحقق من رمز OTP الذي أدخله المستخدم.
  Future<AuthResponse> verifyOtp({
    required String phone,
    required String otp,
  }) {
    return _client.auth.verifyOTP(
      phone: phone,
      token: otp,
      type: OtpType.sms,
    );
  }

  /// يُستدعى بعد أول تسجيل دخول ناجح لإنشاء صف في جدول users العام.
  Future<void> createUserProfile({
    required String fullName,
    required String role, // 'customer' | 'provider'
  }) async {
    final userId = _client.auth.currentUser!.id;
    final phone = _client.auth.currentUser!.phone!;
    await _client.from('users').upsert({
      'id': userId,
      'phone': phone,
      'full_name': fullName,
      'role': role,
    });
  }

  Future<void> signOut() => _client.auth.signOut();

  bool get isLoggedIn => _client.auth.currentUser != null;
}
