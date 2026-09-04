import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/app_colors.dart';

class ShimmerJobCard extends StatelessWidget {
  const ShimmerJobCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade200,
        highlightColor: Colors.grey.shade50,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 16,
                        width: double.infinity,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 12,
                        width: 140,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Container(height: 22, width: 90, color: Colors.white),
                const SizedBox(width: 8),
                Container(height: 22, width: 70, color: Colors.white),
                const SizedBox(width: 8),
                Container(height: 22, width: 110, color: Colors.white),
              ],
            ),
            const SizedBox(height: 12),
            Container(height: 12, width: double.infinity, color: Colors.white),
            const SizedBox(height: 6),
            Container(height: 12, width: 220, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
