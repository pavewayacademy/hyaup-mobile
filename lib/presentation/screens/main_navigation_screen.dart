import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../data/repositories/job_repository.dart';
import '../../repository/auth.dart';
import 'auth/auth_gateway_modal.dart';
import 'comparison/comparison_screen.dart';
import 'profile/profile_screen.dart';
import 'search/search_feed_screen.dart';
import 'tracker/application_tracker_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialTab;

  const MainNavigationScreen({super.key, this.initialTab = 0});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;
  final JobRepository _jobRepo = JobRepository();
  final AuthRepository _authRepo = AuthRepository();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
  }

  void _promptAuth(String featureName, int targetTab) {
    AuthGatewayModal.show(
      context,
      actionTitle: featureName,
      onSuccess: () {
        setState(() {
          _currentIndex = targetTab;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isAuthenticated = _authRepo.isAuthenticated;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          // Tab 0: Discover (Open to both unauthenticated and authenticated users)
          SearchFeedScreen(
            onApplicationsUpdated: () => setState(() {}),
          ),

          // Tab 1: Compare Matrix
          FutureBuilder(
            future: _jobRepo.searchJobs(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.length >= 2) {
                return ComparisonScreen(
                  jobs: snapshot.data!.take(3).toList(),
                  onRemoveJob: (_) {},
                );
              }
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            },
          ),

          // Tab 2: Tracker (Auth-gated)
          isAuthenticated
              ? const ApplicationTrackerScreen()
              : _buildAuthGatedScreen(
                  icon: Icons.assignment_turned_in_rounded,
                  title: "Track Your Job Pipeline",
                  subtitle:
                      "Sign in to organize your submitted applications, track external employer redirects, and access saved opportunities.",
                  featureName: "access your application pipeline",
                  targetTab: 2,
                ),

          // Tab 3: Profile & AI Hub (Auth-gated)
          isAuthenticated
              ? ProfileScreen(
                  onJobCreated: () {
                    setState(() => _currentIndex = 0);
                  },
                )
              : _buildAuthGatedScreen(
                  icon: Icons.psychology_rounded,
                  title: "AI Candidate Profile Hub",
                  subtitle:
                      "Sign in to upload your CV, chat with the AI Career Agent, and configure your personalized skills vector.",
                  featureName: "access your AI Career Profile",
                  targetTab: 3,
                ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if ((index == 2 || index == 3) && !_authRepo.isAuthenticated) {
            _promptAuth(index == 2 ? "view your applications" : "view your candidate profile", index);
            return;
          }
          setState(() => _currentIndex = index);
        },
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textTertiary,
        selectedLabelStyle: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.bold),
        unselectedLabelStyle: AppTypography.labelSmall,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore_rounded),
            label: "Discover",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.compare_arrows_outlined),
            activeIcon: Icon(Icons.compare_arrows_rounded),
            label: "Compare",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment_turned_in_rounded),
            label: "Tracker",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: "Profile",
          ),
        ],
      ),
    );
  }

  Widget _buildAuthGatedScreen({
    required IconData icon,
    required String title,
    required String subtitle,
    required String featureName,
    required int targetTab,
  }) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.primary, size: 36),
              ),
              const SizedBox(height: 20),
              Text(title, style: AppTypography.headlineMedium, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: AppTypography.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _promptAuth(featureName, targetTab),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text("Sign In or Create Account"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
