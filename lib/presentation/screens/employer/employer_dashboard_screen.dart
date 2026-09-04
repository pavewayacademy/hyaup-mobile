import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/app_preferences.dart';
import '../../../data/models/job_model.dart';
import '../../../data/repositories/job_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../repository/auth.dart';
import '../intro/intro_screen.dart';
import '../main_navigation_screen.dart';
import 'post_job_modal.dart';

class EmployerDashboardScreen extends StatefulWidget {
  const EmployerDashboardScreen({super.key});

  @override
  State<EmployerDashboardScreen> createState() => _EmployerDashboardScreenState();
}

class _EmployerDashboardScreenState extends State<EmployerDashboardScreen> with SingleTickerProviderStateMixin {
  final JobRepository _jobRepo = JobRepository();
  final UserRepository _userRepo = UserRepository();
  final AuthRepository _authRepo = AuthRepository();

  late TabController _tabController;
  List<JobModel> _postedJobs = [];
  bool _isLoading = true;

  final List<Map<String, dynamic>> _applicantPool = [
    {
      'name': 'Christian Enow',
      'role': 'Senior Flutter & AI Mobile Engineer',
      'match_score': 0.94,
      'location': 'Douala, Cameroon',
      'experience': '5 years (Mobile & Dart)',
      'status': 'Reviewing',
    },
    {
      'name': 'Blandine Talla',
      'role': 'Backend Core Architect (FastAPI)',
      'match_score': 0.89,
      'location': 'Yaoundé, Cameroon',
      'experience': '4 years (Python, PostgreSQL)',
      'status': 'Interviewing',
    },
    {
      'name': 'Marc-Aurel Kamga',
      'role': 'Fintech Mobile Developer',
      'match_score': 0.82,
      'location': 'Douala, Cameroon',
      'experience': '3 years (Flutter, Mobile Money)',
      'status': 'New',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final jobs = await _jobRepo.searchJobs();
    if (mounted) {
      setState(() {
        _postedJobs = jobs.where((j) => j.isNative).toList();
        _isLoading = false;
      });
    }
  }

  void _switchToJobSeeker() async {
    await AppPreferences.setUserRole("professional");
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
      );
    }
  }

  void _signOut() async {
    await _authRepo.signOut();
    await AppPreferences.clearPreferences();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const IntroScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = _userRepo.currentProfile;
    final companyName = profile?['company_name'] ?? "Paveway & Nexus Tech";
    final city = profile?['city'] ?? "Douala, Cameroon";

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Employer Center", style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
            Text(
              "$companyName • $city",
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 11),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (val) {
              if (val == 'switch') {
                _switchToJobSeeker();
              } else if (val == 'signout') {
                _signOut();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'switch',
                child: Row(
                  children: [
                    Icon(Icons.swap_horiz_rounded, size: 20),
                    SizedBox(width: 8),
                    Text("Switch to Job Seeker Mode"),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'signout',
                child: Row(
                  children: [
                    Icon(Icons.logout_rounded, color: AppColors.rose, size: 20),
                    SizedBox(width: 8),
                    Text("Sign Out", style: TextStyle(color: AppColors.rose)),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textTertiary,
          indicatorColor: AppColors.primary,
          labelStyle: AppTypography.titleSmall,
          tabs: [
            Tab(text: "My Postings (${_postedJobs.length})"),
            Tab(text: "Applicants (${_applicantPool.length})"),
          ],
        ),
      ),
      body: Column(
        children: [
          // KPI Metric Cards
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppColors.surface,
            child: Row(
              children: [
                _buildKpiCard("Active Jobs", "${_postedJobs.length}", AppColors.primary),
                const SizedBox(width: 10),
                _buildKpiCard("Total Applicants", "${_applicantPool.length}", AppColors.emerald),
                const SizedBox(width: 10),
                _buildKpiCard("High AI Matches", "2", AppColors.amber),
              ],
            ),
          ),

          const Divider(height: 1),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Postings Tab
                _buildPostingsTab(),
                // Applicants Tab
                _buildApplicantsTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          PostJobModal.show(
            context,
            onJobCreated: _loadDashboardData,
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text("Post a Job", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildKpiCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color)),
            const SizedBox(height: 2),
            Text(label, style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildPostingsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_postedJobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.post_add_rounded, size: 64, color: AppColors.textTertiary),
            const SizedBox(height: 12),
            Text("No active job postings yet", style: AppTypography.titleMedium),
            const SizedBox(height: 4),
            Text("Tap the button below to publish your first role.", style: AppTypography.bodySmall),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _postedJobs.length,
      itemBuilder: (context, index) {
        final job = _postedJobs[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.emeraldLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      "Active & Vectorized",
                      style: AppTypography.labelSmall.copyWith(color: AppColors.emerald, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    job.remoteMode.toUpperCase(),
                    style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(job.title, style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(job.location, style: AppTypography.bodySmall),
              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Applicants: 3 candidates", style: AppTypography.bodySmall),
                  TextButton(
                    onPressed: () => _tabController.animateTo(1),
                    child: const Text("View Pipeline"),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildApplicantsTab() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _applicantPool.length,
      itemBuilder: (context, index) {
        final applicant = _applicantPool[index];
        final int score = ((applicant['match_score'] as double) * 100).round();

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    applicant['name'],
                    style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.emeraldLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.auto_awesome_rounded, size: 12, color: AppColors.emerald),
                        const SizedBox(width: 4),
                        Text(
                          "$score% AI Match",
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.emerald,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(applicant['role'], style: AppTypography.bodySmall.copyWith(color: AppColors.primary)),
              Text("${applicant['location']} • ${applicant['experience']}", style: AppTypography.bodySmall),
              const SizedBox(height: 12),
              Row(
                children: [
                  OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Candidate ${applicant['name']} shortlisted.")),
                      );
                    },
                    style: OutlinedButton.styleFrom(visualDensity: VisualDensity.compact),
                    child: const Text("Shortlist"),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Interview invitation sent to ${applicant['name']}.")),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      visualDensity: VisualDensity.compact,
                    ),
                    child: const Text("Schedule Interview"),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
