import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;
  final VoidCallback onFilterTap;
  final int activeFilterCount;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
    required this.onFilterTap,
    this.activeFilterCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.surface,
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: controller,
                maxLength: 500,
                buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
                textInputAction: TextInputAction.search,
                onChanged: onChanged,
                onSubmitted: onSubmitted,
                decoration: InputDecoration(
                  hintText: "Job title, skill, or 'Remote Flutter'...",
                  hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textTertiary),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.textSecondary,
                    size: 22,
                  ),
                  suffixIcon: controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.textTertiary),
                          onPressed: onClear,
                        )
                      : null,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Filter Button with Badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              InkWell(
                onTap: onFilterTap,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: activeFilterCount > 0 ? AppColors.primaryContainer : AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: activeFilterCount > 0 ? AppColors.primary : AppColors.border,
                      width: activeFilterCount > 0 ? 1.5 : 1,
                    ),
                  ),
                  child: Icon(
                    Icons.tune_rounded,
                    color: activeFilterCount > 0 ? AppColors.primary : AppColors.textSecondary,
                    size: 22,
                  ),
                ),
              ),
              if (activeFilterCount > 0)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      "$activeFilterCount",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
