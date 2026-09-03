import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'otp_screen.dart';

class PhoneEntryScreen extends StatefulWidget {
  final String role;
  const PhoneEntryScreen({super.key, required this.role});

  @override
  State<PhoneEntryScreen> createState() => _PhoneEntryScreenState();
}

class _PhoneEntryScreenState extends State<PhoneEntryScreen> {
  final _authService = AuthService();
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  Future<void> _sendOtp() async {
    final rawPhone = _phoneController.text.trim();
    if (rawPhone.length < 8) {
      setState(() => _error = 'أدخل رقم هاتف صحيح');
      return;
    }
    // موريتانيا: كود الدولة +222
    final fullPhone = '+222$rawPhone';

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await _authService.sendOtp(fullPhone);
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => OtpScreen(phone: fullPhone, role: widget.role),
        ),
      );
    } catch (e) {
      setState(() => _error = 'تعذّر إرسال الرمز، حاول مجددًا');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('أدخل رقم هاتفك',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('سنرسل لك رمز تحقق عبر رسالة نصية'),
            const SizedBox(height: 24),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              textDirection: TextDirection.ltr,
              decoration: InputDecoration(
                prefixText: '+222 ',
                hintText: '4X XX XX XX',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                errorText: _error,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _sendOtp,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('إرسال الرمز'),
            ),
          ],
        ),
      ),
    );
  }
}
