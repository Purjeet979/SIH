import 'package:flutter/material.dart';
import 'theme.dart';
import 'landing_page.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_page.dart';
import 'env.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RuleScan App',
      theme: AppTheme.lightTheme,
      home: Supabase.instance.client.auth.currentUser != null ? const HomePage() : const LandingPage(),
    );
  }
}
