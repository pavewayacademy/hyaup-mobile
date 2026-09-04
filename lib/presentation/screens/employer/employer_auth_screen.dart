import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/app_preferences.dart';
import '../../../repository/auth.dart';
import 'employer_dashboard_screen.dart';
import 'employer_onboarding_screen.dart';

class EmployerAuthScreen extends StatefulWidget {
  final bool isSignUp;

  const EmployerAuthScreen({super.key, this.isSignUp = true});

  @override
  State<EmployerAuthScreen> createState() => _EmployerAuthScreenState();
}

class _EmployerAuthScreenState extends State<EmployerAuthScreen> {
  final AuthRepository _authRepo = AuthRepository();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _companyController = TextEditingController();

  late bool _isSignUp;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _isSignUp = widget.isSignUp;
  }

  Future<void> _handleAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final companyName = _companyController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = "Please enter both official email and password.");
      return;
    }

    if (_isSignUp && companyName.isEmpty) {
      setState(() => _error = "Please enter your company / organization name.");
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      if (_isSignUp) {
        await _authRepo.createUserWithEmailAndPassword(email, password);
      } else {
        await _authRepo.signInWithEmailAndPassword(email, password);
      }

      await AppPreferences.setUserRole("employer");
      final bool alreadyOnboarded = await AppPreferences.isOnboarded();

      if (mounted) {
        if (!alreadyOnboarded || _isSignUp) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => EmployerOnboardingScreen(initialCompanyName: companyName),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const EmployerDashboardScreen()),
          );
        }
      }
    } catch (e) {
      setState(() {
        _error = e.toString().contains("]") ? e.toString().split("]").last.trim() : e.toString();
        _isLoading = false;
      });
    }
  }

  void _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    // In production, triggers GoogleSignIn. For MVP demonstration:
    await Future.delayed(const Duration(milliseconds: 600));
    await AppPreferences.setUserRole("employer");

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const EmployerOnboardingScreen(initialCompanyName: "HyaUp Enterprise"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isSignUp ? "Employer Registration" : "Employer Sign In"),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Employer Branding Icon
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.business_center_rounded, color: AppColors.primary, size: 34),
                ),
              ),
              const SizedBox(height: 20),

              Text(
                _isSignUp ? "Hire Top Talent in Cameroon" : "Welcome Back, Employer",
                style: AppTypography.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                _isSignUp
                    ? "Create your company account to post jobs and review AI-evaluated candidates."
                    : "Manage your active listings and incoming applications.",
                style: AppTypography.bodySmall,
                textAlign: TextAlign.center,
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

              if (_isSignUp) ...[
                TextFormField(
                  controller: _companyController,
                  decoration: const InputDecoration(
                    labelText: "Company / Organization Name *",
                    prefixIcon: Icon(Icons.apartment_rounded),
                    hintText: "e.g. MTN Cameroon, Paveway, UN",
                  ),
                ),
                const SizedBox(height: 14),
              ],

              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: "Work Email Address *",
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password *",
                  prefixIcon: Icon(Icons.lock_outline_rounded),
                ),
              ),
              const SizedBox(height: 24),

              // Submit Action
              ElevatedButton(
                onPressed: _isLoading ? null : _handleAuth,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: AppColors.primary,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(_isSignUp ? "Create Employer Account" : "Sign In to Employer Center"),
              ),
              const SizedBox(height: 14),

              // Google Sign-In Button
              OutlinedButton.icon(
                onPressed: _isLoading ? null : _handleGoogleSignIn,
                icon: const Icon(Icons.g_mobiledata_rounded, size: 28),
                label: const Text("Continue with Google"),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: AppColors.border),
                  foregroundColor: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              // Switch Sign In / Sign Up
              Center(
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _isSignUp = !_isSignUp;
                      _error = null;
                    });
                  },
                  child: Text(
                    _isSignUp
                        ? "Already registered? Sign In to Employer Center"
                        : "New recruiter? Create company account",
                    style: AppTypography.labelLarge,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
