import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/app_preferences.dart';
import '../employer/employer_auth_screen.dart';
import '../main_navigation_screen.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _pageController = PageController();
  int _currentSlide = 0;

  final List<Map<String, dynamic>> _slides = [
    {
      'title': "AI-Driven Career Discovery in Cameroon",
      'subtitle':
          "Search thousands of roles in plain language. Our pgvector semantic engine surfaces high-match opportunities under 300ms.",
      'icon': Icons.auto_awesome_rounded,
      'badge': "Vector Match",
    },
    {
      'title': "Dual-Source Opportunity Engine",
      'subtitle':
          "Explore native direct employer postings alongside verified regional and international web job listings in one unified feed.",
      'icon': Icons.hub_rounded,
      'badge': "Unified Feed",
    },
    {
      'title': "LangGraph Multi-Agent Matchmaking",
      'subtitle':
          "Get objective compatibility scorecards evaluated by simulated Candidate Advocate and Recruiter Mirror AI agents.",
      'icon': Icons.psychology_rounded,
      'badge': "Agentic AI",
    },
  ];

  void _selectJobSeeker() async {
    await AppPreferences.setHasSeenIntro(true);
    await AppPreferences.setUserRole("professional");

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
      );
    }
  }

  void _selectEmployer() async {
    await AppPreferences.setHasSeenIntro(true);
    await AppPreferences.setUserRole("employer");

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const EmployerAuthScreen(isSignUp: true)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Brand Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          "HYAUP",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Cameroon",
                        style: AppTypography.titleSmall.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: _selectJobSeeker,
                    child: Text(
                      "Explore as Guest",
                      style: AppTypography.labelSmall.copyWith(color: AppColors.primary),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Feature Highlights Carousel
              Expanded(
                flex: 5,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _slides.length,
                  onPageChanged: (index) => setState(() => _currentSlide = index),
                  itemBuilder: (context, index) {
                    final slide = _slides[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(slide['icon'] as IconData, size: 44, color: AppColors.primary),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.emeraldLight,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            slide['badge'] as String,
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.emerald,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          slide['title'] as String,
                          style: AppTypography.headlineMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          slide['subtitle'] as String,
                          style: AppTypography.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  },
                ),
              ),

              // Carousel Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _slides.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentSlide == index ? 22 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentSlide == index ? AppColors.primary : AppColors.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Role Selection Header
              Text(
                "Choose how you want to use HyaUp:",
                style: AppTypography.titleSmall.copyWith(color: AppColors.textPrimary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Option 1: Job Seeker Card (Direct Search Access)
              _buildRoleCard(
                icon: Icons.person_search_rounded,
                title: "I am looking for a Job",
                subtitle: "Search Cameroonian & remote roles, evaluate with AI, apply directly",
                isPrimary: true,
                onTap: _selectJobSeeker,
              ),

              const SizedBox(height: 12),

              // Option 2: Employer Card (Direct to Account Creation & Onboarding)
              _buildRoleCard(
                icon: Icons.business_center_rounded,
                title: "I am an Employer / Recruiter",
                subtitle: "Post vacancies, discover AI-screened candidates, manage hires",
                isPrimary: false,
                onTap: _selectEmployer,
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primaryContainer : AppColors.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isPrimary ? AppColors.primary : AppColors.border,
            width: isPrimary ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isPrimary ? AppColors.primary : AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isPrimary ? Colors.white : AppColors.textPrimary,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.titleSmall.copyWith(
                      color: isPrimary ? AppColors.primaryDark : AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: isPrimary ? AppColors.textSecondary : AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: isPrimary ? AppColors.primary : AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
