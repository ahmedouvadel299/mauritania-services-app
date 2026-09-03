import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class CompleteProfileScreen extends StatefulWidget {
  final String role;
  const CompleteProfileScreen({super.key, required this.role});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _authService = AuthService();
  final _nameController = TextEditingController();
  bool _isLoading = false;

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) return;
    setState(() => _isLoading = true);
    try {
      await _authService.createUserProfile(
        fullName: _nameController.text.trim(),
        role: widget.role,
      );
      // TODO: التنقل حسب الدور:
      // - customer → الصفحة الرئيسية
      // - provider  → استمارة تسجيل مقدم الخدمة (بيانات الهوية والتخصص)
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إنشاء الحساب بنجاح')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('أكمل بياناتك')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'الاسم الكامل',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _save,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('متابعة'),
            ),
          ],
        ),
      ),
    );
  }
}
