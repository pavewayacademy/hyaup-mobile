import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';

class MatchScoreBadge extends StatelessWidget {
  final double? score; // 0.0 to 1.0 or percentage
  final bool showLabel;

  const MatchScoreBadge({
    super.key,
    required this.score,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    if (score == null) return const SizedBox.shrink();

    final int percentage = score! > 1 ? score!.round() : (score! * 100).round();

    Color bgColor;
    Color textColor;
    IconData icon;

    if (percentage >= 85) {
      bgColor = AppColors.emeraldLight;
      textColor = AppColors.emerald;
      icon = Icons.auto_awesome_rounded;
    } else if (percentage >= 70) {
      bgColor = AppColors.amberLight;
      textColor = AppColors.amber;
      icon = Icons.bolt_rounded;
    } else {
      bgColor = AppColors.externalBadgeBg;
      textColor = AppColors.textSecondary;
      icon = Icons.check_circle_outline_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: textColor.withValues(alpha: 0.25), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: textColor),
          const SizedBox(width: 4),
          Text(
            "$percentage% ${showLabel ? 'Match' : ''}".trim(),
            style: AppTypography.labelSmall.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
