import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../data/models/filter_model.dart';

class JobFilterModal extends StatefulWidget {
  final FilterModel currentFilter;
  final ValueChanged<FilterModel> onApply;

  const JobFilterModal({
    super.key,
    required this.currentFilter,
    required this.onApply,
  });

  static void show(
    BuildContext context, {
    required FilterModel currentFilter,
    required ValueChanged<FilterModel> onApply,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => JobFilterModal(
        currentFilter: currentFilter,
        onApply: onApply,
      ),
    );
  }

  @override
  State<JobFilterModal> createState() => _JobFilterModalState();
}

class _JobFilterModalState extends State<JobFilterModal> {
  late num? _minSalary;
  late bool? _hasPaidPto;
  late bool? _hasHealthCoverage;
  late String? _remoteMode;
  late String? _sourceType;

  final formatter = NumberFormat('#,###', 'en_US');

  @override
  void initState() {
    super.initState();
    _minSalary = widget.currentFilter.minSalary;
    _hasPaidPto = widget.currentFilter.hasPaidPto;
    _hasHealthCoverage = widget.currentFilter.hasHealthCoverage;
    _remoteMode = widget.currentFilter.remoteMode;
    _sourceType = widget.currentFilter.sourceType;
  }

  void _reset() {
    setState(() {
      _minSalary = null;
      _hasPaidPto = false;
      _hasHealthCoverage = false;
      _remoteMode = null;
      _sourceType = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
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
                TextButton(
                  onPressed: _reset,
                  child: Text(
                    "Reset",
                    style: AppTypography.titleSmall.copyWith(color: AppColors.textTertiary),
                  ),
                ),
                Text(
                  "Filter Jobs",
                  style: AppTypography.headlineSmall,
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Filter controls
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Source Origin Filter
                Text("Source Origin", style: AppTypography.titleSmall),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildSelectablePill(
                      label: "All Sources",
                      isSelected: _sourceType == null || _sourceType!.isEmpty,
                      onTap: () => setState(() => _sourceType = null),
                    ),
                    const SizedBox(width: 8),
                    _buildSelectablePill(
                      label: "Direct Employer",
                      isSelected: _sourceType == 'native',
                      onTap: () => setState(() => _sourceType = 'native'),
                    ),
                    const SizedBox(width: 8),
                    _buildSelectablePill(
                      label: "External Web",
                      isSelected: _sourceType == 'external',
                      onTap: () => setState(() => _sourceType = 'external'),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Base Salary Range
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Minimum Salary", style: AppTypography.titleSmall),
                    Text(
                      _minSalary != null && _minSalary! > 0
                          ? "${formatter.format(_minSalary)} FCFA/mo"
                          : "Any Salary",
                      style: AppTypography.titleSmall.copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Slider(
                  value: (_minSalary ?? 0).toDouble().clamp(0, 1500000),
                  min: 0,
                  max: 1500000,
                  divisions: 15,
                  label: _minSalary != null && _minSalary! > 0 ? "${formatter.format(_minSalary)} FCFA" : "Any",
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    setState(() {
                      _minSalary = val > 0 ? val.round() : null;
                    });
                  },
                ),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildSalaryPreset(250000),
                    _buildSalaryPreset(500000),
                    _buildSalaryPreset(750000),
                    _buildSalaryPreset(1000000),
                  ],
                ),

                const SizedBox(height: 24),

                // Work Location Arrangement
                Text("Work Arrangement", style: AppTypography.titleSmall),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildSelectablePill(
                      label: "Any Mode",
                      isSelected: _remoteMode == null,
                      onTap: () => setState(() => _remoteMode = null),
                    ),
                    const SizedBox(width: 8),
                    _buildSelectablePill(
                      label: "Remote",
                      isSelected: _remoteMode == 'remote',
                      onTap: () => setState(() => _remoteMode = 'remote'),
                    ),
                    const SizedBox(width: 8),
                    _buildSelectablePill(
                      label: "Hybrid",
                      isSelected: _remoteMode == 'hybrid',
                      onTap: () => setState(() => _remoteMode = 'hybrid'),
                    ),
                    const SizedBox(width: 8),
                    _buildSelectablePill(
                      label: "Onsite",
                      isSelected: _remoteMode == 'onsite',
                      onTap: () => setState(() => _remoteMode = 'onsite'),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Benefits Toggles (Paid PTO & Health Coverage)
                Text("Benefits Baseline", style: AppTypography.titleSmall),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: Text("Paid Vacation (PTO)", style: AppTypography.bodyMedium),
                        subtitle: Text("Roles with confirmed paid time-off", style: AppTypography.bodySmall),
                        value: _hasPaidPto == true,
                        activeThumbColor: AppColors.primary,
                        onChanged: (val) => setState(() => _hasPaidPto = val),
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        title: Text("Medical & Health Coverage", style: AppTypography.bodyMedium),
                        subtitle: Text("Includes comprehensive healthcare coverage", style: AppTypography.bodySmall),
                        value: _hasHealthCoverage == true,
                        activeThumbColor: AppColors.primary,
                        onChanged: (val) => setState(() => _hasHealthCoverage = val),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Apply Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final updated = FilterModel(
                      minSalary: _minSalary,
                      hasPaidPto: _hasPaidPto,
                      hasHealthCoverage: _hasHealthCoverage,
                      remoteMode: _remoteMode,
                      sourceType: _sourceType,
                    );
                    widget.onApply(updated);
                    Navigator.pop(context);
                  },
                  child: const Text("Apply Filters"),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectablePill({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryContainer : AppColors.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: isSelected ? AppColors.primaryDark : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildSalaryPreset(num amount) {
    final isSelected = _minSalary == amount;
    return ActionChip(
      label: Text("${formatter.format(amount)} FCFA+"),
      backgroundColor: isSelected ? AppColors.primaryContainer : AppColors.background,
      labelStyle: AppTypography.labelSmall.copyWith(
        color: isSelected ? AppColors.primaryDark : AppColors.textSecondary,
      ),
      onPressed: () {
        setState(() {
          _minSalary = isSelected ? null : amount;
        });
      },
    );
  }
}
