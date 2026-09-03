import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../services/auth_service.dart';
import 'complete_profile_screen.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  final String role;
  const OtpScreen({super.key, required this.phone, required this.role});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _authService = AuthService();
  String _otp = '';
  bool _isLoading = false;
  String? _error;

  Future<void> _verify() async {
    if (_otp.length != 6) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await _authService.verifyOtp(phone: widget.phone, otp: _otp);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => CompleteProfileScreen(role: widget.role),
        ),
      );
    } catch (e) {
      setState(() => _error = 'رمز غير صحيح، حاول مجددًا');
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
            const Text('أدخل رمز التحقق',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('تم إرساله إلى ${widget.phone}'),
            const SizedBox(height: 24),
            PinCodeTextField(
              appContext: context,
              length: 6,
              onChanged: (v) => setState(() => _otp = v),
              onCompleted: (_) => _verify(),
              keyboardType: TextInputType.number,
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(10),
                fieldHeight: 50,
                fieldWidth: 44,
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _verify,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('تأكيد'),
            ),
          ],
        ),
      ),
    );
  }
}
