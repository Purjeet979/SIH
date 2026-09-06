import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const String officerEmail = 'officer@rulescan.com';
  static const String officerPassword = 'Purjeet@9506';
  static const String adminEmail = 'admin@rulescan.com';
  static const String adminPassword = 'admin123';

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true; // toggle between Login / Sign Up
  String _selectedRole = 'officer';
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _applyDemoRole('officer');
  }

  void _applyDemoRole(String role) {
    setState(() {
      _selectedRole = role;
      if (role == 'admin') {
        _emailController.text = adminEmail;
        _passwordController.text = adminPassword;
      } else {
        _emailController.text = officerEmail;
        _passwordController.text = officerPassword;
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Please enter email and password'),
          backgroundColor: AppTheme.violationRed,
        ),
      );
      return;
    }

    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      // Determine role purely for UI routing based on email (as per demo design)
      final role = (email == adminEmail) ? 'admin' : 'officer';

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomePage(role: role)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Login failed: ${e.toString()}'),
            backgroundColor: AppTheme.violationRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceBase,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.verified, color: Colors.white, size: 28),
                ),
                const SizedBox(height: 16),
                Text('RuleScan', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  _isLogin ? 'Welcome back' : 'Create your account',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),

                // Auth Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.borderSubtle),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Toggle: Sign In / Sign Up
                      Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceSubtle,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _isLogin = true),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  decoration: BoxDecoration(
                                    color: _isLogin ? Colors.white : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: _isLogin
                                        ? [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 4, offset: const Offset(0, 1))]
                                        : null,
                                  ),
                                  margin: const EdgeInsets.all(3),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Sign In',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: _isLogin ? AppTheme.textPrimary : AppTheme.textTertiary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _isLogin = false),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  decoration: BoxDecoration(
                                    color: !_isLogin ? Colors.white : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: !_isLogin
                                        ? [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 4, offset: const Offset(0, 1))]
                                        : null,
                                  ),
                                  margin: const EdgeInsets.all(3),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Sign Up',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: !_isLogin ? AppTheme.textPrimary : AppTheme.textTertiary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Role Selector
                      Text('Select Role', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _applyDemoRole('officer'),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  color: _selectedRole == 'officer' ? AppTheme.primaryBlueLight : AppTheme.surfaceSubtle,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _selectedRole == 'officer' ? AppTheme.primaryBlue : AppTheme.borderSubtle,
                                    width: _selectedRole == 'officer' ? 2 : 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(Icons.badge_outlined, size: 24, color: _selectedRole == 'officer' ? AppTheme.primaryBlue : AppTheme.textTertiary),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Officer',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: _selectedRole == 'officer' ? AppTheme.primaryBlue : AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _applyDemoRole('admin'),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  color: _selectedRole == 'admin' ? AppTheme.primaryBlueLight : AppTheme.surfaceSubtle,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _selectedRole == 'admin' ? AppTheme.primaryBlue : AppTheme.borderSubtle,
                                    width: _selectedRole == 'admin' ? 2 : 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(Icons.admin_panel_settings_outlined, size: 24, color: _selectedRole == 'admin' ? AppTheme.primaryBlue : AppTheme.textTertiary),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Admin',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: _selectedRole == 'admin' ? AppTheme.primaryBlue : AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Demo Account Credentials Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: _selectedRole == 'admin' ? const Color(0xFFF5F3FF) : AppTheme.primaryBlueLight,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _selectedRole == 'admin' ? const Color(0xFFDDD6FE) : AppTheme.borderSubtle,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _selectedRole == 'admin' ? Icons.shield_outlined : Icons.verified_user_outlined,
                              size: 15,
                              color: _selectedRole == 'admin' ? const Color(0xFF7C3AED) : AppTheme.primaryBlue,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _selectedRole == 'admin' ? 'Demo Admin: admin@rulescan.com' : 'Demo Officer: officer@rulescan.com',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: _selectedRole == 'admin' ? const Color(0xFF5B21B6) : AppTheme.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    _selectedRole == 'admin' ? 'Password: admin123 (Full State Oversight)' : 'Password: Purjeet@9506 (Field Scanner)',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: _selectedRole == 'admin' ? const Color(0xFF7C3AED) : AppTheme.primaryBlue,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Email
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          hintText: 'officer@rulescan.com',
                          filled: true,
                          fillColor: AppTheme.surfaceSubtle,
                          prefixIcon: const Icon(Icons.email_outlined, size: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Password
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          filled: true,
                          fillColor: AppTheme.surfaceSubtle,
                          prefixIcon: const Icon(Icons.lock_outline, size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              size: 20,
                              color: AppTheme.textTertiary,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Submit Button
                      ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text(_isLogin ? 'Log In' : 'Create Account'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('← Back to Landing Page', style: TextStyle(color: AppTheme.textTertiary)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
