import 'package:flutter/material.dart';
import 'theme.dart';
import 'landing_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RuleScan App',
      theme: AppTheme.lightTheme,
      home: const LandingPage(),
    );
  }
}
