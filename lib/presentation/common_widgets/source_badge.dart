import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';

class SourceBadge extends StatelessWidget {
  final String sourceType;
  final bool compact;

  const SourceBadge({
    super.key,
    required this.sourceType,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isNative = sourceType.toLowerCase() == 'native';

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: isNative ? AppColors.nativeBadgeBg : AppColors.externalBadgeBg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isNative
              ? AppColors.nativeBadgeText.withValues(alpha: 0.2)
              : AppColors.externalBadgeText.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isNative ? Icons.verified_rounded : Icons.open_in_new_rounded,
            size: compact ? 12 : 14,
            color: isNative ? AppColors.nativeBadgeText : AppColors.externalBadgeText,
          ),
          const SizedBox(width: 5),
          Text(
            isNative ? "Direct Employer" : "External Source",
            style: AppTypography.labelSmall.copyWith(
              color: isNative ? AppColors.nativeBadgeText : AppColors.externalBadgeText,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
