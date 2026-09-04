import 'package:flutter/material.dart';
import 'package:hyaup/core/constants/app_colors.dart';
import 'package:hyaup/core/constants/app_typography.dart';
import 'package:hyaup/core/utils/currency_formatter.dart';
import 'package:hyaup/data/models/job_model.dart';
import 'package:hyaup/presentation/common_widgets/match_score_badge.dart';
import 'package:hyaup/presentation/common_widgets/source_badge.dart';

class JobCard extends StatelessWidget {
  final JobModel job;
  final VoidCallback onTap;
  final bool isBookmarked;
  final VoidCallback onBookmarkTap;
  final bool isSelectedForComparison;
  final ValueChanged<bool?> onCompareToggle;

  const JobCard({
    super.key,
    required this.job,
    required this.onTap,
    required this.isBookmarked,
    required this.onBookmarkTap,
    required this.isSelectedForComparison,
    required this.onCompareToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelectedForComparison ? AppColors.primary : AppColors.border,
          width: isSelectedForComparison ? 1.8 : 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Avatar, Title, Company & Bookmark
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Company Avatar
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        job.company.isNotEmpty ? job.company[0].toUpperCase() : 'C',
                        style: AppTypography.headlineSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Title & Company
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job.title,
                            style: AppTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            "${job.company} • ${job.location}",
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Bookmark Button
                    IconButton(
                      icon: Icon(
                        isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                        color: isBookmarked ? AppColors.primary : AppColors.textTertiary,
                        size: 22,
                      ),
                      onPressed: onBookmarkTap,
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Salary Pill & Badges Row
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SourceBadge(sourceType: job.sourceType, compact: true),
                    if (job.matchScore != null)
                      MatchScoreBadge(score: job.matchScore),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        CurrencyFormatter.formatSalaryRange(
                          min: job.salaryMin,
                          max: job.salaryMax,
                          currency: job.currency,
                        ),
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Benefits & Work Mode Snippets
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    if (job.hasPaidPto)
                      _buildBenefitSnippet(Icons.beach_access_rounded, "Paid PTO"),
                    if (job.hasHealthCoverage)
                      _buildBenefitSnippet(Icons.health_and_safety_rounded, "Health Cover"),
                    _buildBenefitSnippet(
                      job.remoteMode == "remote"
                          ? Icons.home_work_rounded
                          : (job.remoteMode == "hybrid" ? Icons.laptop_mac_rounded : Icons.business_rounded),
                      job.remoteMode[0].toUpperCase() + job.remoteMode.substring(1),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(height: 1, color: AppColors.divider),
                const SizedBox(height: 8),

                // Bottom Row: Time ago & Compare Checkbox
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatPostedTime(job.postedAt),
                      style: AppTypography.bodySmall,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          value: isSelectedForComparison,
                          onChanged: onCompareToggle,
                          activeColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        InkWell(
                          onTap: () => onCompareToggle(!isSelectedForComparison),
                          child: Text(
                            "Compare",
                            style: AppTypography.labelSmall.copyWith(
                              color: isSelectedForComparison ? AppColors.primary : AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitSnippet(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  String _formatPostedTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inHours < 1) {
      return "Posted just now";
    } else if (diff.inHours < 24) {
      return "Posted ${diff.inHours}h ago";
    } else {
      return "Posted ${diff.inDays}d ago";
    }
  }
}
