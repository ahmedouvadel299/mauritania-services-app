import 'package:flutter/material.dart';
import 'email_auth_screen.dart';
import '../../../core/supabase_client.dart';
class ChooseRoleScreen extends StatelessWidget {
  const ChooseRoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SelectableText('رابط: ${AppSupabase.debugUrl}\n${AppSupabase.debugKeyLength}',
                    style: const TextStyle(fontSize: 11, color: Colors.red)),
                const SizedBox(height: 16),
              SelectableText(
                'DEBUG URL: [${const String.fromEnvironment('dummy')}]${Uri.base}',
                style: const TextStyle(fontSize: 10, color: Colors.red),
              ),
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
                onTap: () => _goToAuth(context, 'customer'),
              ),
              const SizedBox(height: 16),
              _RoleCard(
                title: 'أقدّم خدمة',
                subtitle: 'كمقدم خدمة (كهربائي، سباك، ...)',
                icon: Icons.handyman,
                onTap: () => _goToAuth(context, 'provider'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _goToAuth(BuildContext context, String role) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => EmailAuthScreen(role: role)),
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
