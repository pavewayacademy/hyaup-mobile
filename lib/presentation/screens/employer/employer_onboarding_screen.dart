import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../repository/auth.dart';
import 'employer_dashboard_screen.dart';

class EmployerOnboardingScreen extends StatefulWidget {
  final String? initialCompanyName;

  const EmployerOnboardingScreen({super.key, this.initialCompanyName});

  @override
  State<EmployerOnboardingScreen> createState() => _EmployerOnboardingScreenState();
}

class _EmployerOnboardingScreenState extends State<EmployerOnboardingScreen> {
  final UserRepository _userRepo = UserRepository();
  final AuthRepository _authRepo = AuthRepository();

  late final TextEditingController _companyController;
  final _phoneController = TextEditingController();
  final _websiteController = TextEditingController();
  final _bioController = TextEditingController();

  String _selectedIndustry = "Technology & Software";
  String _selectedCity = "Douala";
  final String _companySize = "11-50 employees";
  bool _isSubmitting = false;

  final List<String> _industries = [
    "Technology & Software",
    "Banking & Fintech",
    "Telecommunications",
    "Healthcare & NGO",
    "Logistics & Supply Chain",
    "Energy & Utilities",
  ];

  final List<String> _cities = [
    "Douala",
    "Yaoundé",
    "Bafoussam",
    "Buea",
    "Garoua",
    "Remote in Cameroon",
  ];

  @override
  void initState() {
    super.initState();
    _companyController = TextEditingController(text: widget.initialCompanyName ?? "");
  }

  Future<void> _handleComplete() async {
    final companyName = _companyController.text.trim();
    if (companyName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please provide your company name.")),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final user = _authRepo.currentUser;
    final uid = user?.uid ?? "employer-${DateTime.now().millisecondsSinceEpoch}";
    final email = user?.email ?? "recruiter@hyaup.com";

    await _userRepo.saveOnboardingProfile(
      uid: uid,
      email: email,
      role: "employer",
      onboardingData: {
        'company_name': companyName,
        'industry': _selectedIndustry,
        'city': _selectedCity,
        'company_size': _companySize,
        'phone': _phoneController.text.trim(),
        'website': _websiteController.text.trim(),
        'bio': _bioController.text.trim(),
      },
    );

    setState(() => _isSubmitting = false);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const EmployerDashboardScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Company Onboarding"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Step Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "STEP 1 OF 1",
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "Company Profile Setup",
                style: AppTypography.titleSmall.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "Tell us about your organization",
            style: AppTypography.headlineMedium,
          ),
          const SizedBox(height: 6),
          Text(
            "This profile appears on your direct job postings and informs candidate match algorithms.",
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: 24),

          TextField(
            controller: _companyController,
            decoration: const InputDecoration(
              labelText: "Official Company Name *",
              hintText: "e.g. MTN Cameroon",
              prefixIcon: Icon(Icons.business_rounded),
            ),
          ),
          const SizedBox(height: 16),

          // Industry Dropdown
          DropdownButtonFormField<String>(
            initialValue: _selectedIndustry,
            decoration: const InputDecoration(
              labelText: "Primary Industry *",
              prefixIcon: Icon(Icons.category_rounded),
            ),
            items: _industries.map((ind) {
              return DropdownMenuItem(value: ind, child: Text(ind));
            }).toList(),
            onChanged: (val) => setState(() => _selectedIndustry = val!),
          ),
          const SizedBox(height: 16),

          // Cameroon City Dropdown
          DropdownButtonFormField<String>(
            initialValue: _selectedCity,
            decoration: const InputDecoration(
              labelText: "Primary Office City (Cameroon) *",
              prefixIcon: Icon(Icons.location_on_rounded),
            ),
            items: _cities.map((city) {
              return DropdownMenuItem(value: city, child: Text(city));
            }).toList(),
            onChanged: (val) => setState(() => _selectedCity = val!),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: "Contact Phone / WhatsApp",
              hintText: "+237 6XX XXX XXX",
              prefixIcon: Icon(Icons.phone_rounded),
            ),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _websiteController,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
              labelText: "Company Website or LinkedIn",
              hintText: "https://yourcompany.cm",
              prefixIcon: Icon(Icons.link_rounded),
            ),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _bioController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: "Company Overview / Mission",
              hintText: "Briefly introduce what your team builds and your work culture...",
            ),
          ),
          const SizedBox(height: 32),

          ElevatedButton(
            onPressed: _isSubmitting ? null : _handleComplete,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Text("Complete Setup & Open Employer Center"),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
