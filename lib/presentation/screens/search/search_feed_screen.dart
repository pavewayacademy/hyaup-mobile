import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../data/models/filter_model.dart';
import '../../../data/models/job_model.dart';
import '../../../data/repositories/application_repository.dart';
import '../../../data/repositories/job_repository.dart';
import '../../common_widgets/filter_chip_bar.dart';
import '../../common_widgets/search_bar_widget.dart';
import '../../common_widgets/shimmer_job_card.dart';
import '../comparison/comparison_dock.dart';
import '../filter/job_filter_modal.dart';
import '../auth/auth_gateway_modal.dart';
import '../../../repository/auth.dart';
import 'job_detail_sheet.dart';
import 'widgets/job_card.dart';

class SearchFeedScreen extends StatefulWidget {
  final VoidCallback? onApplicationsUpdated;

  const SearchFeedScreen({super.key, this.onApplicationsUpdated});

  @override
  State<SearchFeedScreen> createState() => _SearchFeedScreenState();
}

class _SearchFeedScreenState extends State<SearchFeedScreen> {
  final JobRepository _jobRepo = JobRepository();
  final ApplicationRepository _appRepo = ApplicationRepository();
  final AuthRepository _authRepo = AuthRepository();
  final TextEditingController _searchController = TextEditingController();

  List<JobModel> _jobs = [];
  final List<JobModel> _selectedForComparison = [];
  FilterModel _currentFilter = const FilterModel();
  bool _isLoading = true;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _fetchJobs();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchJobs() async {
    setState(() => _isLoading = true);
    final results = await _jobRepo.searchJobs(
      query: _searchController.text,
      filter: _currentFilter,
    );

    if (mounted) {
      setState(() {
        _jobs = results;
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String val) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      _fetchJobs();
    });
  }

  void _toggleComparison(JobModel job, bool isSelected) {
    setState(() {
      if (isSelected) {
        if (_selectedForComparison.length >= 3) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("You can compare up to 3 roles at a time.")),
          );
          return;
        }
        _selectedForComparison.add(job);
      } else {
        _selectedForComparison.removeWhere((j) => j.id == job.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                "HYAUP",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              "Cameroon AI Job Search",
              style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Search Input Header
              SearchBarWidget(
                controller: _searchController,
                onChanged: _onSearchChanged,
                onSubmitted: (_) => _fetchJobs(),
                onClear: () {
                  _searchController.clear();
                  _fetchJobs();
                },
                activeFilterCount: _currentFilter.activeFilterCount,
                onFilterTap: () {
                  JobFilterModal.show(
                    context,
                    currentFilter: _currentFilter,
                    onApply: (updated) {
                      setState(() => _currentFilter = updated);
                      _fetchJobs();
                    },
                  );
                },
              ),

              // Filter Chips Strip
              FilterChipBar(
                filter: _currentFilter,
                onFilterChanged: (updated) {
                  setState(() => _currentFilter = updated);
                  _fetchJobs();
                },
                onClearAll: () {
                  setState(() => _currentFilter = const FilterModel());
                  _fetchJobs();
                },
              ),

              // Feed Metrics Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _isLoading ? "Discovering opportunities..." : "${_jobs.length} Opportunities Found",
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.bolt_rounded, size: 14, color: AppColors.emerald),
                        const SizedBox(width: 2),
                        Text(
                          "pgvector Semantic Rank",
                          style: AppTypography.labelSmall.copyWith(color: AppColors.emerald),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Results Feed
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _fetchJobs,
                  color: AppColors.primary,
                  child: _isLoading
                      ? ListView.builder(
                          itemCount: 4,
                          itemBuilder: (context, index) => const ShimmerJobCard(),
                        )
                      : _jobs.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              padding: const EdgeInsets.only(bottom: 80),
                              itemCount: _jobs.length,
                              itemBuilder: (context, index) {
                                final job = _jobs[index];
                                final isCompared = _selectedForComparison.any((j) => j.id == job.id);
                                final isBookmarked = _appRepo.isJobBookmarked(job.id);

                                return JobCard(
                                  job: job,
                                  isBookmarked: isBookmarked,
                                  isSelectedForComparison: isCompared,
                                  onTap: () {
                                    JobDetailSheet.show(
                                      context,
                                      job,
                                      onApplicationSubmitted: () {
                                        setState(() {});
                                        widget.onApplicationsUpdated?.call();
                                      },
                                    );
                                  },
                                  onBookmarkTap: () {
                                    if (!_authRepo.isAuthenticated) {
                                      AuthGatewayModal.show(
                                        context,
                                        actionTitle: "save ${job.title}",
                                        onSuccess: () {
                                          setState(() {
                                            _appRepo.toggleBookmark(job);
                                          });
                                          widget.onApplicationsUpdated?.call();
                                        },
                                      );
                                      return;
                                    }
                                    setState(() {
                                      _appRepo.toggleBookmark(job);
                                    });
                                    widget.onApplicationsUpdated?.call();
                                  },
                                  onCompareToggle: (selected) {
                                    _toggleComparison(job, selected ?? false);
                                  },
                                );
                              },
                            ),
                ),
              ),
            ],
          ),

          // Floating Comparison Dock (if 1-3 jobs selected)
          ComparisonDock(
            selectedJobs: _selectedForComparison,
            onClear: () => setState(() => _selectedForComparison.clear()),
            onRemoveJob: (job) => setState(() => _selectedForComparison.removeWhere((j) => j.id == job.id)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 64, color: AppColors.textTertiary.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(
              "No matching opportunities found",
              style: AppTypography.titleMedium.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 6),
            Text(
              "Try broadening your search terms or clearing active filters.",
              style: AppTypography.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _searchController.clear();
                setState(() => _currentFilter = const FilterModel());
                _fetchJobs();
              },
              child: const Text("Reset Search & Filters"),
            ),
          ],
        ),
      ),
    );
  }
}
