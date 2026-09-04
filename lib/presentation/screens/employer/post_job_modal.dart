import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../data/repositories/job_repository.dart';

class PostJobModal extends StatefulWidget {
  final VoidCallback onJobCreated;

  const PostJobModal({super.key, required this.onJobCreated});

  static void show(BuildContext context, {required VoidCallback onJobCreated}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PostJobModal(onJobCreated: onJobCreated),
    );
  }

  @override
  State<PostJobModal> createState() => _PostJobModalState();
}

class _PostJobModalState extends State<PostJobModal> {
  final JobRepository _jobRepo = JobRepository();

  final _titleController = TextEditingController();
  final _companyController = TextEditingController();
  final _locationController = TextEditingController(text: "Douala, Cameroon");
  final _minSalaryController = TextEditingController(text: "500000");
  final _maxSalaryController = TextEditingController(text: "850000");
  final _skillsController = TextEditingController(text: "Flutter, Dart, Firebase");
  final _descriptionController = TextEditingController();

  String _remoteMode = "hybrid";
  bool _hasPaidPto = true;
  bool _hasHealthCoverage = true;
  bool _isSubmitting = false;

  Future<void> _submitJob() async {
    final title = _titleController.text.trim();
    final company = _companyController.text.trim();
    final desc = _descriptionController.text.trim();

    if (title.isEmpty || company.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in job title and company name.")),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final skills = _skillsController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final payload = {
      'title': title,
      'company': company,
      'location': _locationController.text.trim(),
      'description': desc.isNotEmpty ? desc : "Full-time role based in Cameroon with competitive benefits.",
      'salary_min': num.tryParse(_minSalaryController.text),
      'salary_max': num.tryParse(_maxSalaryController.text),
      'currency': "XAF",
      'has_paid_pto': _hasPaidPto,
      'has_health_coverage': _hasHealthCoverage,
      'remote_mode': _remoteMode,
      'required_skills': skills,
    };

    await _jobRepo.createJob(payload);

    setState(() => _isSubmitting = false);

    if (mounted) {
      Navigator.pop(context);
      widget.onJobCreated();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Job posted and vectorized successfully!"),
          backgroundColor: AppColors.emerald,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.add_business_rounded, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text("Post a New Job", style: AppTypography.headlineSmall),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Form fields
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: "Job Title *",
                    hintText: "e.g. Senior Mobile Engineer",
                  ),
                ),
                const SizedBox(height: 14),

                TextField(
                  controller: _companyController,
                  decoration: const InputDecoration(
                    labelText: "Company Name *",
                    hintText: "e.g. MTN Cameroon",
                  ),
                ),
                const SizedBox(height: 14),

                TextField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: "Location",
                    hintText: "e.g. Yaoundé, Cameroon",
                  ),
                ),
                const SizedBox(height: 14),

                // Work Mode
                Text("Work Arrangement", style: AppTypography.titleSmall),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildModeChip("onsite", "Onsite"),
                    const SizedBox(width: 8),
                    _buildModeChip("hybrid", "Hybrid"),
                    const SizedBox(width: 8),
                    _buildModeChip("remote", "Remote"),
                  ],
                ),
                const SizedBox(height: 14),

                // Salary Range (Min & Max in FCFA)
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _minSalaryController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Min Salary (FCFA)",
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _maxSalaryController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Max Salary (FCFA)",
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                TextField(
                  controller: _skillsController,
                  decoration: const InputDecoration(
                    labelText: "Required Skills (comma separated)",
                    hintText: "Flutter, Dart, Firebase, PostgreSQL",
                  ),
                ),
                const SizedBox(height: 14),

                // Benefits toggles
                SwitchListTile(
                  title: Text("Paid Vacation (PTO)", style: AppTypography.bodyMedium),
                  value: _hasPaidPto,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) => setState(() => _hasPaidPto = val),
                ),
                SwitchListTile(
                  title: Text("Health Insurance Coverage", style: AppTypography.bodyMedium),
                  value: _hasHealthCoverage,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) => setState(() => _hasHealthCoverage = val),
                ),
                const SizedBox(height: 14),

                TextField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: "Job Description & Responsibilities",
                    hintText: "Describe the responsibilities, tech stack, and ideal candidate...",
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),

          // Submit Action
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submitJob,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.publish_rounded),
                  label: Text(_isSubmitting ? "Vectorizing Opportunity..." : "Publish Job Post"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeChip(String mode, String label) {
    final isSelected = _remoteMode == mode;
    return Expanded(
      child: ChoiceChip(
        label: Center(child: Text(label)),
        selected: isSelected,
        selectedColor: AppColors.primaryContainer,
        labelStyle: AppTypography.labelSmall.copyWith(
          color: isSelected ? AppColors.primaryDark : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        onSelected: (selected) {
          if (selected) setState(() => _remoteMode = mode);
        },
      ),
    );
  }
}
