import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../data/models/job_model.dart';
import 'comparison_screen.dart';

class ComparisonDock extends StatelessWidget {
  final List<JobModel> selectedJobs;
  final VoidCallback onClear;
  final Function(JobModel) onRemoveJob;

  const ComparisonDock({
    super.key,
    required this.selectedJobs,
    required this.onClear,
    required this.onRemoveJob,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedJobs.isEmpty) return const SizedBox.shrink();

    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A), // Dark slate
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Selected Job count badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "${selectedJobs.length}/3",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Compare Roles",
                    style: AppTypography.titleSmall.copyWith(color: Colors.white),
                  ),
                  Text(
                    "Side-by-side analysis",
                    style: AppTypography.bodySmall.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: onClear,
              child: const Text("Clear", style: TextStyle(color: Colors.white60)),
            ),
            const SizedBox(width: 4),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ComparisonScreen(
                      jobs: selectedJobs,
                      onRemoveJob: onRemoveJob,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.emerald,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: const Text("View Matrix"),
            ),
          ],
        ),
      ),
    );
  }
}
