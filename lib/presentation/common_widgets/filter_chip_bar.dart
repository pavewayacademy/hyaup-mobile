import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../data/models/filter_model.dart';

class FilterChipBar extends StatelessWidget {
  final FilterModel filter;
  final Function(FilterModel updatedFilter) onFilterChanged;
  final VoidCallback onClearAll;

  const FilterChipBar({
    super.key,
    required this.filter,
    required this.onFilterChanged,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    if (filter.isEmpty) return const SizedBox.shrink();

    final List<Widget> chips = [];
    final formatter = NumberFormat('#,###', 'en_US');

    if (filter.minSalary != null && filter.minSalary! > 0) {
      chips.add(
        _buildChip(
          label: "${formatter.format(filter.minSalary)} FCFA+",
          onDelete: () => onFilterChanged(filter.copyWith(clearMinSalary: true)),
        ),
      );
    }

    if (filter.hasPaidPto == true) {
      chips.add(
        _buildChip(
          label: "Paid PTO",
          onDelete: () => onFilterChanged(filter.copyWith(hasPaidPto: false)),
        ),
      );
    }

    if (filter.hasHealthCoverage == true) {
      chips.add(
        _buildChip(
          label: "Health Insurance",
          onDelete: () => onFilterChanged(filter.copyWith(hasHealthCoverage: false)),
        ),
      );
    }

    if (filter.remoteMode != null && filter.remoteMode!.isNotEmpty) {
      chips.add(
        _buildChip(
          label: "Mode: ${filter.remoteMode![0].toUpperCase()}${filter.remoteMode!.substring(1)}",
          onDelete: () => onFilterChanged(filter.copyWith(clearRemoteMode: true)),
        ),
      );
    }

    if (filter.sourceType != null && filter.sourceType!.isNotEmpty) {
      final isNative = filter.sourceType!.toLowerCase() == 'native';
      chips.add(
        _buildChip(
          label: isNative ? "Direct Employers Only" : "External Jobs Only",
          onDelete: () => onFilterChanged(filter.copyWith(clearSourceType: true)),
        ),
      );
    }

    return Container(
      height: 42,
      margin: const EdgeInsets.only(top: 6, bottom: 6),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          ...chips,
          TextButton(
            onPressed: onClearAll,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              visualDensity: VisualDensity.compact,
            ),
            child: Text(
              "Clear all",
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required VoidCallback onDelete,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.primaryDark,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: onDelete,
            borderRadius: BorderRadius.circular(10),
            child: const Icon(
              Icons.close_rounded,
              size: 14,
              color: AppColors.primaryDark,
            ),
          ),
        ],
      ),
    );
  }
}
