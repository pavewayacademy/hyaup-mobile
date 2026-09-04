import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../presentation/screens/main_navigation_screen.dart';
import '../../repository/auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthRepository _authRepository = AuthRepository();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isSignUp = false;
  bool _isLoading = false;
  String? _error;

  Future<void> _handleAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = "Please enter both email and password");
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      if (_isSignUp) {
        await _authRepository.createUserWithEmailAndPassword(email, password);
      } else {
        await _authRepository.signInWithEmailAndPassword(email, password);
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString().contains("]") ? e.toString().split("]").last.trim() : e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isSignUp ? "Create HyaUp Account" : "Sign In to HyaUp"),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.work_rounded, color: AppColors.primary, size: 32),
              ),
              const SizedBox(height: 20),
              Text(
                _isSignUp ? "Find Top Roles in Cameroon" : "Welcome Back",
                style: AppTypography.headlineMedium,
              ),
              const SizedBox(height: 6),
              Text(
                _isSignUp
                    ? "Create your profile to get matched by AI"
                    : "Access your saved jobs, applications, and AI scorecard",
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: 24),
              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.roseLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _error!,
                    style: AppTypography.bodySmall.copyWith(color: AppColors.rose),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: "Email Address",
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password",
                  prefixIcon: Icon(Icons.lock_outline_rounded),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleAuth,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(_isSignUp ? "Sign Up" : "Sign In"),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isSignUp = !_isSignUp;
                    _error = null;
                  });
                },
                child: Text(
                  _isSignUp ? "Already have an account? Sign In" : "New candidate? Create account",
                  style: AppTypography.labelLarge,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
