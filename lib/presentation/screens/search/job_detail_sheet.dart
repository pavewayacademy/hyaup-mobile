import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/url_helper.dart';
import '../../../data/models/job_model.dart';
import '../../../data/repositories/application_repository.dart';
import '../../../repository/auth.dart';
import '../../common_widgets/match_score_badge.dart';
import '../../common_widgets/source_badge.dart';
import '../ai_match/ai_match_modal.dart';
import '../auth/auth_gateway_modal.dart';

class JobDetailSheet extends StatefulWidget {
  final JobModel job;
  final VoidCallback? onApplicationSubmitted;

  const JobDetailSheet({
    super.key,
    required this.job,
    this.onApplicationSubmitted,
  });

  static void show(BuildContext context, JobModel job, {VoidCallback? onApplicationSubmitted}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => JobDetailSheet(
        job: job,
        onApplicationSubmitted: onApplicationSubmitted,
      ),
    );
  }

  @override
  State<JobDetailSheet> createState() => _JobDetailSheetState();
}

class _JobDetailSheetState extends State<JobDetailSheet> {
  final ApplicationRepository _applicationRepo = ApplicationRepository();
  final AuthRepository _authRepo = AuthRepository();
  bool _isApplying = false;

  @override
  Widget build(BuildContext context) {
    final bool isBookmarked = _applicationRepo.isJobBookmarked(widget.job.id);

    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Drag handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 6),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header actions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                            color: isBookmarked ? AppColors.primary : AppColors.textSecondary,
                          ),
                          onPressed: () {
                            setState(() {
                              _applicationRepo.toggleBookmark(widget.job);
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Scrollable Job Specs & Description
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Source & Match Badges
                    Row(
                      children: [
                        SourceBadge(sourceType: widget.job.sourceType),
                        const SizedBox(width: 8),
                        if (widget.job.matchScore != null)
                          MatchScoreBadge(score: widget.job.matchScore),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Title
                    Text(
                      widget.job.title,
                      style: AppTypography.headlineMedium,
                    ),

                    const SizedBox(height: 6),

                    // Company & Location
                    Text(
                      "${widget.job.company} • ${widget.job.location}",
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Compensation & Benefits Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Job Highlights & Compensation",
                            style: AppTypography.titleSmall.copyWith(color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 12),
                          _buildDetailRow(
                            icon: Icons.payments_outlined,
                            title: "Salary Range",
                            value: CurrencyFormatter.formatSalaryRange(
                              min: widget.job.salaryMin,
                              max: widget.job.salaryMax,
                              currency: widget.job.currency,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildDetailRow(
                            icon: Icons.work_outline_rounded,
                            title: "Work Policy",
                            value: "${widget.job.remoteMode[0].toUpperCase()}${widget.job.remoteMode.substring(1)} arrangement",
                          ),
                          const SizedBox(height: 8),
                          _buildDetailRow(
                            icon: Icons.beach_access_outlined,
                            title: "Paid Vacation",
                            value: widget.job.hasPaidPto ? "Paid PTO included" : "Standard labor terms",
                          ),
                          const SizedBox(height: 8),
                          _buildDetailRow(
                            icon: Icons.health_and_safety_outlined,
                            title: "Health Coverage",
                            value: widget.job.hasHealthCoverage ? "Medical insurance provided" : "Not covered",
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // LangGraph AI Match Banner
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFEFF6FF), Color(0xFFE0F2FE)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "AI Candidate Match Analysis",
                                  style: AppTypography.titleSmall.copyWith(color: AppColors.primaryDark),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "Multi-agent review (Candidate Advocate vs Recruiter Mirror)",
                                  style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              AiMatchModal.show(context, widget.job);
                            },
                            child: Text(
                              "View Report",
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Required Skills Section
                    if (widget.job.requiredSkills.isNotEmpty) ...[
                      Text("Required Skills", style: AppTypography.titleSmall),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: widget.job.requiredSkills.map((skill) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Text(
                              skill,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Full Job Description
                    Text("Role Description", style: AppTypography.titleSmall),
                    const SizedBox(height: 8),
                    Text(
                      widget.job.description.isNotEmpty
                          ? widget.job.description
                          : "No detailed description provided by the employer.",
                      style: AppTypography.bodyMedium,
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),

              // Fixed Action Bar (Source-Aware CTAs)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      // AI Evaluation Secondary Action
                      Expanded(
                        flex: 1,
                        child: OutlinedButton.icon(
                          onPressed: () => AiMatchModal.show(context, widget.job),
                          icon: const Icon(Icons.psychology_rounded, size: 18),
                          label: const Text("AI Report"),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Primary CTA (Native vs External)
                      Expanded(
                        flex: 2,
                        child: widget.job.isNative
                            ? ElevatedButton.icon(
                                onPressed: _isApplying ? null : _handleNativeApply,
                                icon: _isApplying
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                      )
                                    : const Icon(Icons.flash_on_rounded, size: 18),
                                label: Text(_isApplying ? "Submitting..." : "Apply with AI Match"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.emerald,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                              )
                            : ElevatedButton.icon(
                                onPressed: () => _handleExternalApply(context),
                                icon: const Icon(Icons.open_in_new_rounded, size: 18),
                                label: const Text("Apply on Original Site"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Text(
          "$title: ",
          style: AppTypography.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _handleNativeApply() async {
    // Check if user is authenticated
    if (!_authRepo.isAuthenticated) {
      AuthGatewayModal.show(
        context,
        actionTitle: "Apply to ${widget.job.title}",
        onSuccess: () {
          _executeNativeApply();
        },
      );
      return;
    }

    _executeNativeApply();
  }

  void _executeNativeApply() async {
    setState(() => _isApplying = true);
    await _applicationRepo.submitNativeApplication(widget.job);
    setState(() => _isApplying = false);

    widget.onApplicationSubmitted?.call();

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Application successfully submitted to ${widget.job.company}!"),
          backgroundColor: AppColors.emerald,
        ),
      );
    }
  }

  void _handleExternalApply(BuildContext context) {
    // Log redirect telemetry and launch URL
    _applicationRepo.trackExternalRedirect(widget.job);
    UrlHelper.openExternalUrl(context, widget.job.externalApplyUrl);
    widget.onApplicationSubmitted?.call();
  }
}
