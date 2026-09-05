import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_page.dart';
import 'login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://ganoupqtsujbtrikhiia.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdhbm91cHF0c3VqYnRyaWtoaWlhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODg2MjQyMDQsImV4cCI6MjEwNDIwMDIwNH0.tySQFHOj3VMOcEAU469yca_5nYNok0286yYmnC1j6aY',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RuleScan App',
      theme: ThemeData(primarySwatch: Colors.blueGrey, useMaterial3: true),
      home: Supabase.instance.client.auth.currentUser != null ? const HomePage() : const LoginPage(),
    );
  }
}
