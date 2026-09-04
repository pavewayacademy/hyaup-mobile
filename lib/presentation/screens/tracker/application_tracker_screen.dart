import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/url_helper.dart';
import '../../../data/models/application_model.dart';
import '../../../data/repositories/application_repository.dart';
import '../../common_widgets/source_badge.dart';

class ApplicationTrackerScreen extends StatefulWidget {
  const ApplicationTrackerScreen({super.key});

  @override
  State<ApplicationTrackerScreen> createState() => _ApplicationTrackerScreenState();
}

class _ApplicationTrackerScreenState extends State<ApplicationTrackerScreen> with SingleTickerProviderStateMixin {
  final ApplicationRepository _appRepo = ApplicationRepository();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allApps = _appRepo.getApplications();

    final submittedApps = allApps.where((a) => a.isSubmitted).toList();
    final redirectApps = allApps.where((a) => a.isExternalRedirect).toList();
    final savedApps = allApps.where((a) => a.isSaved).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Job Applications"),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textTertiary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: AppTypography.titleSmall,
          tabs: [
            Tab(text: "All (${allApps.length})"),
            Tab(text: "Direct (${submittedApps.length})"),
            Tab(text: "Redirects (${redirectApps.length})"),
            Tab(text: "Saved (${savedApps.length})"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAppList(allApps),
          _buildAppList(submittedApps),
          _buildAppList(redirectApps),
          _buildAppList(savedApps),
        ],
      ),
    );
  }

  Widget _buildAppList(List<ApplicationModel> apps) {
    if (apps.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open_rounded, size: 64, color: AppColors.textTertiary.withValues(alpha: 0.5)),
            const SizedBox(height: 14),
            Text(
              "No applications in this category",
              style: AppTypography.titleMedium.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 6),
            Text(
              "Jobs you apply for or save will be organized here.",
              style: AppTypography.bodySmall,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: apps.length,
      itemBuilder: (context, index) {
        final app = apps[index];
        return _buildApplicationCard(app);
      },
    );
  }

  Widget _buildApplicationCard(ApplicationModel app) {
    final dateStr = DateFormat('MMM dd, yyyy').format(app.timestamp);

    Color statusColor;
    String statusLabel;
    IconData statusIcon;

    if (app.isSubmitted) {
      statusColor = AppColors.emerald;
      statusLabel = "Application Submitted";
      statusIcon = Icons.check_circle_rounded;
    } else if (app.isExternalRedirect) {
      statusColor = AppColors.primary;
      statusLabel = "External Redirect Tracked";
      statusIcon = Icons.open_in_new_rounded;
    } else {
      statusColor = AppColors.amber;
      statusLabel = "Saved Listing";
      statusIcon = Icons.bookmark_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SourceBadge(sourceType: app.sourceType, compact: true),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 12, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      statusLabel,
                      style: AppTypography.labelSmall.copyWith(color: statusColor, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            app.jobTitle,
            style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 3),
          Text(
            "${app.companyName} • ${app.location}",
            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Logged on $dateStr",
                style: AppTypography.bodySmall,
              ),
              if (app.externalUrl != null)
                TextButton.icon(
                  onPressed: () {
                    UrlHelper.openExternalUrl(context, app.externalUrl);
                  },
                  icon: const Icon(Icons.link_rounded, size: 14),
                  label: const Text("Open Link"),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
