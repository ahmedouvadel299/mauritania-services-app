import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/app_theme.dart';
import 'core/supabase_client.dart';
import 'features/auth/screens/choose_role_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppSupabase.init();
  runApp(const MauritaniaServicesApp());
}

class MauritaniaServicesApp extends StatelessWidget {
  const MauritaniaServicesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'منصة الخدمات',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('fr')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        // فرض اتجاه RTL على كامل التطبيق بغض النظر عن اللغة الحالية للجهاز
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      home: const ChooseRoleScreen(),
    );
  }
}
