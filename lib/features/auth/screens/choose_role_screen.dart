import 'package:flutter/material.dart';
import 'phone_entry_screen.dart';

class ChooseRoleScreen extends StatelessWidget {
  const ChooseRoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'كيف تريد استخدام التطبيق؟',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              _RoleCard(
                title: 'أبحث عن خدمة',
                subtitle: 'كعميل يريد حجز مقدمي خدمات',
                icon: Icons.search,
                onTap: () => _goToPhone(context, 'customer'),
              ),
              const SizedBox(height: 16),
              _RoleCard(
                title: 'أقدّم خدمة',
                subtitle: 'كمقدم خدمة (كهربائي، سباك، ...)',
                icon: Icons.handyman,
                onTap: () => _goToPhone(context, 'provider'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _goToPhone(BuildContext context, String role) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PhoneEntryScreen(role: role)),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(icon, size: 36, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: TextStyle(color: Colors.grey.shade600)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_back_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
