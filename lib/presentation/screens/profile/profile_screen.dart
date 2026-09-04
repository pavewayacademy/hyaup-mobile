import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../repository/auth.dart';
import '../auth/auth_gateway_modal.dart';
import '../employer/post_job_modal.dart';
import '../onboarding/conversational_ai_screen.dart';
import '../onboarding/resume_upload_screen.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onJobCreated;

  const ProfileScreen({super.key, this.onJobCreated});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthRepository _authRepo = AuthRepository();

  @override
  Widget build(BuildContext context) {
    final user = _authRepo.currentUser;
    final bool isAuthenticated = user != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile & AI Career Hub"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Profile Header Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.primaryContainer,
                  child: Text(
                    isAuthenticated ? (user.email?[0].toUpperCase() ?? 'U') : 'G',
                    style: AppTypography.headlineMedium.copyWith(color: AppColors.primary),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAuthenticated ? (user.displayName ?? user.email?.split('@').first ?? "Professional") : "Guest Job Seeker",
                        style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isAuthenticated ? user.email! : "Sign in to save jobs and apply with AI",
                        style: AppTypography.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      if (!isAuthenticated)
                        ElevatedButton(
                          onPressed: () {
                            AuthGatewayModal.show(
                              context,
                              actionTitle: "access your profile",
                              onSuccess: () => setState(() {}),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            visualDensity: VisualDensity.compact,
                          ),
                          child: const Text("Sign In / Register"),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Vector Profile Status Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.hub_rounded, color: Color(0xFF34D399), size: 32),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "AI Vector Profile",
                        style: AppTypography.titleSmall.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Indexed in pgvector for sub-300ms semantic distance matching",
                        style: AppTypography.bodySmall.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Hub Action Cards
          Text("Career Tools & Ingestion", style: AppTypography.titleSmall),
          const SizedBox(height: 10),

          _buildHubOption(
            icon: Icons.upload_file_rounded,
            title: "Upload / Update Resume",
            subtitle: "Extract skills automatically via PDF/DOCX",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ResumeUploadScreen()),
              );
            },
          ),
          const SizedBox(height: 10),

          _buildHubOption(
            icon: Icons.smart_toy_rounded,
            title: "Chat with AI Career Agent",
            subtitle: "Synthesize profile skills via conversation",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ConversationalAiScreen()),
              );
            },
          ),
          const SizedBox(height: 10),

          _buildHubOption(
            icon: Icons.add_business_rounded,
            title: "Post a Job (Recruiter Mode)",
            subtitle: "Publish and vectorize a role for Cameroonian talent",
            onTap: () {
              PostJobModal.show(
                context,
                onJobCreated: () {
                  widget.onJobCreated?.call();
                },
              );
            },
          ),

          const SizedBox(height: 24),

          // Candidate Skills Cloud
          Text("Verified Skills Cloud", style: AppTypography.titleSmall),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              "Flutter",
              "Dart",
              "Firebase",
              "Python",
              "FastAPI",
              "PostgreSQL",
              "pgvector",
              "REST APIs",
              "Mobile Money",
            ].map((skill) {
              return Chip(
                label: Text(skill),
                backgroundColor: AppColors.background,
                side: const BorderSide(color: AppColors.border),
                labelStyle: AppTypography.labelSmall.copyWith(color: AppColors.textPrimary),
              );
            }).toList(),
          ),

          const SizedBox(height: 30),

          if (isAuthenticated)
            OutlinedButton.icon(
              onPressed: () async {
                await _authRepo.signOut();
                setState(() {});
              },
              icon: const Icon(Icons.logout_rounded, color: AppColors.rose),
              label: Text("Sign Out", style: TextStyle(color: AppColors.rose)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.rose),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildHubOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.titleSmall),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTypography.bodySmall),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}
