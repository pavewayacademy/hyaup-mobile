import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/app_preferences.dart';
import '../../../repository/auth.dart';
import '../onboarding/candidate_onboarding_screen.dart';

class AuthGatewayModal extends StatefulWidget {
  final String actionTitle;
  final VoidCallback onSuccess;

  const AuthGatewayModal({
    super.key,
    required this.actionTitle,
    required this.onSuccess,
  });

  static void show(
    BuildContext context, {
    required String actionTitle,
    required VoidCallback onSuccess,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AuthGatewayModal(
        actionTitle: actionTitle,
        onSuccess: onSuccess,
      ),
    );
  }

  @override
  State<AuthGatewayModal> createState() => _AuthGatewayModalState();
}

class _AuthGatewayModalState extends State<AuthGatewayModal> {
  final AuthRepository _authRepo = AuthRepository();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  bool _isSignUp = false;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleSubmit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = "Please enter both email and password.");
      return;
    }

    if (password.length < 6) {
      setState(() => _errorMessage = "Password must be at least 6 characters.");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isSignUp) {
        await _authRepo.createUserWithEmailAndPassword(email, password);
      } else {
        await _authRepo.signInWithEmailAndPassword(email, password);
      }

      await AppPreferences.setUserRole("professional");
      final bool alreadyOnboarded = await AppPreferences.isOnboarded();

      if (mounted) {
        Navigator.pop(context);
        if (!alreadyOnboarded || _isSignUp) {
          CandidateOnboardingScreen.show(context, onComplete: widget.onSuccess);
        } else {
          widget.onSuccess();
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().contains("] ")
            ? e.toString().split("] ").last
            : "Authentication error. Please verify your credentials.";
        _isLoading = false;
      });
    }
  }

  void _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    await AppPreferences.setUserRole("professional");

    if (mounted) {
      Navigator.pop(context);
      CandidateOnboardingScreen.show(context, onComplete: widget.onSuccess);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isSignUp ? "Create your HyaUp Account" : "Welcome Back",
                        style: AppTypography.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Sign in to ${widget.actionTitle}",
                        style: AppTypography.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),

            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.roseLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: AppColors.rose, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: AppTypography.bodySmall.copyWith(color: AppColors.rose),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            if (_isSignUp) ...[
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Full Name",
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
              ),
              const SizedBox(height: 12),
            ],

            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: "Email Address",
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
                prefixIcon: Icon(Icons.lock_outline_rounded),
              ),
            ),
            const SizedBox(height: 20),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(_isSignUp ? "Create Account & Continue" : "Sign In & Continue"),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isLoading ? null : _handleGoogleSignIn,
                icon: const Icon(Icons.g_mobiledata_rounded, size: 28),
                label: const Text("Continue with Google"),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  side: const BorderSide(color: AppColors.border),
                  foregroundColor: AppColors.textPrimary,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Toggle Sign In / Sign Up
            Center(
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _isSignUp = !_isSignUp;
                    _errorMessage = null;
                  });
                },
                child: Text(
                  _isSignUp
                      ? "Already have an account? Sign In"
                      : "New to HyaUp? Create an account",
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
