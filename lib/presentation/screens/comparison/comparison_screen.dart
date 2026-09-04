import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/url_helper.dart';
import '../../../data/models/job_model.dart';
import '../../../data/repositories/application_repository.dart';
import '../../common_widgets/match_score_badge.dart';
import '../../common_widgets/source_badge.dart';

class ComparisonScreen extends StatefulWidget {
  final List<JobModel> jobs;
  final Function(JobModel) onRemoveJob;

  const ComparisonScreen({
    super.key,
    required this.jobs,
    required this.onRemoveJob,
  });

  @override
  State<ComparisonScreen> createState() => _ComparisonScreenState();
}

class _ComparisonScreenState extends State<ComparisonScreen> {
  late List<JobModel> _currentJobs;
  final ApplicationRepository _applicationRepo = ApplicationRepository();

  @override
  void initState() {
    super.initState();
    _currentJobs = List.from(widget.jobs);
  }

  void _removeJob(JobModel job) {
    widget.onRemoveJob(job);
    setState(() {
      _currentJobs.removeWhere((j) => j.id == job.id);
    });
    if (_currentJobs.isEmpty) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Job Comparison Matrix"),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                "${_currentJobs.length} of 3 Roles",
                style: AppTypography.bodySmall,
              ),
            ),
          ),
        ],
      ),
      body: _currentJobs.isEmpty
          ? const Center(child: Text("No jobs selected for comparison"))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _currentJobs.map((job) => _buildJobColumn(job)).toList(),
                ),
              ),
            ),
    );
  }

  Widget _buildJobColumn(JobModel job) {
    const double columnWidth = 260;

    return Container(
      width: columnWidth,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              border: const Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SourceBadge(sourceType: job.sourceType, compact: true),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18),
                      onPressed: () => _removeJob(job),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  job.title,
                  style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  job.company,
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 2),
                Text(
                  job.location,
                  style: AppTypography.bodySmall,
                ),
              ],
            ),
          ),

          // Row 1: AI Match Score
          _buildMatrixCell(
            label: "AI Match Score",
            child: job.matchScore != null
                ? MatchScoreBadge(score: job.matchScore)
                : const Text("Not computed", style: TextStyle(color: AppColors.textTertiary)),
          ),

          // Row 2: Salary Range
          _buildMatrixCell(
            label: "Compensation",
            child: Text(
              CurrencyFormatter.formatSalaryRange(
                min: job.salaryMin,
                max: job.salaryMax,
                currency: job.currency,
              ),
              style: AppTypography.titleSmall.copyWith(color: AppColors.primary),
            ),
          ),

          // Row 3: Work Mode
          _buildMatrixCell(
            label: "Work Arrangement",
            child: Row(
              children: [
                Icon(
                  job.remoteMode == "remote"
                      ? Icons.home_work_rounded
                      : (job.remoteMode == "hybrid" ? Icons.laptop_mac_rounded : Icons.business_rounded),
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  job.remoteMode[0].toUpperCase() + job.remoteMode.substring(1),
                  style: AppTypography.bodyMedium,
                ),
              ],
            ),
          ),

          // Row 4: Paid Vacation / PTO
          _buildMatrixCell(
            label: "Paid Vacation (PTO)",
            child: Row(
              children: [
                Icon(
                  job.hasPaidPto ? Icons.check_circle_rounded : Icons.cancel_outlined,
                  size: 18,
                  color: job.hasPaidPto ? AppColors.emerald : AppColors.textTertiary,
                ),
                const SizedBox(width: 6),
                Text(
                  job.hasPaidPto ? "Paid PTO" : "Unpaid / Standard",
                  style: AppTypography.bodyMedium,
                ),
              ],
            ),
          ),

          // Row 5: Health Coverage
          _buildMatrixCell(
            label: "Health Coverage",
            child: Row(
              children: [
                Icon(
                  job.hasHealthCoverage ? Icons.check_circle_rounded : Icons.cancel_outlined,
                  size: 18,
                  color: job.hasHealthCoverage ? AppColors.emerald : AppColors.textTertiary,
                ),
                const SizedBox(width: 6),
                Text(
                  job.hasHealthCoverage ? "Covered" : "Not Provided",
                  style: AppTypography.bodyMedium,
                ),
              ],
            ),
          ),

          // Row 6: Required Skills
          _buildMatrixCell(
            label: "Required Skills",
            child: Wrap(
              spacing: 4,
              runSpacing: 4,
              children: job.requiredSkills.take(4).map((s) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(s, style: AppTypography.bodySmall.copyWith(fontSize: 10)),
                );
              }).toList(),
            ),
          ),

          // Action CTA
          Padding(
            padding: const EdgeInsets.all(16),
            child: job.isNative
                ? ElevatedButton(
                    onPressed: () async {
                      await _applicationRepo.submitNativeApplication(job);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Application submitted to ${job.company}!"),
                            backgroundColor: AppColors.emerald,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.emerald),
                    child: const Text("Apply with AI"),
                  )
                : OutlinedButton.icon(
                    onPressed: () {
                      _applicationRepo.trackExternalRedirect(job);
                      UrlHelper.openExternalUrl(context, job.externalApplyUrl);
                    },
                    icon: const Icon(Icons.open_in_new_rounded, size: 16),
                    label: const Text("Apply on Site"),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatrixCell({required String label, required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary),
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}
