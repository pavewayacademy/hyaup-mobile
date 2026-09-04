import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../repository/auth.dart';
import 'conversational_ai_screen.dart';
import 'resume_upload_screen.dart';

class CandidateOnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const CandidateOnboardingScreen({super.key, required this.onComplete});

  static void show(BuildContext context, {required VoidCallback onComplete}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CandidateOnboardingScreen(onComplete: onComplete),
      ),
    );
  }

  @override
  State<CandidateOnboardingScreen> createState() => _CandidateOnboardingScreenState();
}

class _CandidateOnboardingScreenState extends State<CandidateOnboardingScreen> {
  final UserRepository _userRepo = UserRepository();
  final AuthRepository _authRepo = AuthRepository();

  final _headlineController = TextEditingController(text: "Software Developer");
  String _selectedCity = "Douala";
  final Set<String> _selectedSkills = {"Flutter", "Dart", "Firebase"};
  bool _isSaving = false;

  final List<String> _availableSkills = [
    "Flutter",
    "Dart",
    "Firebase",
    "Python",
    "FastAPI",
    "PostgreSQL",
    "pgvector",
    "REST APIs",
    "React",
    "Node.js",
    "Mobile Money",
    "Docker",
    "Git",
    "Data Analysis",
  ];

  final List<String> _cities = [
    "Douala",
    "Yaoundé",
    "Buea",
    "Bafoussam",
    "Garoua",
    "Remote in Cameroon",
  ];

  Future<void> _saveAndContinue() async {
    setState(() => _isSaving = true);

    final user = _authRepo.currentUser;
    final uid = user?.uid ?? "candidate-${DateTime.now().millisecondsSinceEpoch}";
    final email = user?.email ?? "candidate@hyaup.com";

    await _userRepo.saveOnboardingProfile(
      uid: uid,
      email: email,
      role: "professional",
      onboardingData: {
        'headline': _headlineController.text.trim(),
        'target_city': _selectedCity,
        'skills': _selectedSkills.toList(),
      },
    );

    setState(() => _isSaving = false);

    if (mounted) {
      Navigator.pop(context);
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Candidate Onboarding"),
        actions: [
          TextButton(
            onPressed: _saveAndContinue,
            child: const Text("Skip"),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "QUICK SETUP",
              style: AppTypography.labelSmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
          Text("Build Your Career Profile", style: AppTypography.headlineMedium),
          const SizedBox(height: 6),
          Text(
            "This information helps our vector engine calculate precise compatibility scores for Cameroonian jobs.",
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: 24),

          TextField(
            controller: _headlineController,
            decoration: const InputDecoration(
              labelText: "Professional Headline *",
              hintText: "e.g. Senior Mobile & AI Engineer",
              prefixIcon: Icon(Icons.badge_rounded),
            ),
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            initialValue: _selectedCity,
            decoration: const InputDecoration(
              labelText: "Preferred City (Cameroon) *",
              prefixIcon: Icon(Icons.location_on_rounded),
            ),
            items: _cities.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (val) => setState(() => _selectedCity = val!),
          ),
          const SizedBox(height: 20),

          Text("Select Your Core Skills", style: AppTypography.titleSmall),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableSkills.map((skill) {
              final isSelected = _selectedSkills.contains(skill);
              return FilterChip(
                label: Text(skill),
                selected: isSelected,
                selectedColor: AppColors.primaryContainer,
                labelStyle: AppTypography.labelSmall.copyWith(
                  color: isSelected ? AppColors.primaryDark : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedSkills.add(skill);
                    } else {
                      _selectedSkills.remove(skill);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Upload or Chat Options
          Text("Enrich with CV or AI Intake", style: AppTypography.titleSmall),
          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ResumeUploadScreen()),
                    );
                  },
                  icon: const Icon(Icons.upload_file_rounded, size: 18),
                  label: const Text("Upload CV"),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ConversationalAiScreen()),
                    );
                  },
                  icon: const Icon(Icons.smart_toy_rounded, size: 18),
                  label: const Text("Chat with AI"),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          ElevatedButton(
            onPressed: _isSaving ? null : _saveAndContinue,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Text("Save Profile & Continue"),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
