import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../data/models/ai_match_model.dart';
import '../../../data/models/job_model.dart';
import '../../../data/repositories/ai_repository.dart';

class AiMatchModal extends StatefulWidget {
  final JobModel job;

  const AiMatchModal({super.key, required this.job});

  static void show(BuildContext context, JobModel job) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AiMatchModal(job: job),
    );
  }

  @override
  State<AiMatchModal> createState() => _AiMatchModalState();
}

class _AiMatchModalState extends State<AiMatchModal> {
  final AiRepository _aiRepo = AiRepository();
  bool _isLoading = true;
  AiMatchModel? _evaluation;

  @override
  void initState() {
    super.initState();
    _loadEvaluation();
  }

  Future<void> _loadEvaluation() async {
    final result = await _aiRepo.evaluateJobMatch(widget.job.id);
    if (mounted) {
      setState(() {
        _evaluation = result;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Drag handle & Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      "LangGraph AI Match",
                      style: AppTypography.headlineSmall,
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(color: AppColors.primary),
                        const SizedBox(height: 16),
                        Text(
                          "Synthesizing Candidate & Recruiter Agents...",
                          style: AppTypography.titleSmall.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Agent A (Advocate) vs Agent B (Recruiter Mirror)",
                          style: AppTypography.bodySmall,
                        ),
                      ],
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      // Scorecard Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Text(
                              "Overall Role Compatibility",
                              style: AppTypography.bodyMedium.copyWith(color: Colors.white70),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "${_evaluation!.matchPercentage}%",
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF34D399), // Emerald highlight
                                letterSpacing: -1,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white12,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _evaluation!.matchPercentage >= 80 ? "Strong Competitive Match" : "Moderate Alignment",
                                style: AppTypography.labelSmall.copyWith(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Dual-Agent Perspective Tabs
                      Text("Multi-Agent Perspectives", style: AppTypography.titleMedium),
                      const SizedBox(height: 12),

                      // Agent A: Candidate Advocate
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFBBF7D0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.sentiment_very_satisfied_rounded, color: AppColors.emerald, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  "Agent A: Candidate Advocate",
                                  style: AppTypography.titleSmall.copyWith(color: AppColors.emerald),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(_evaluation!.advocateSummary, style: AppTypography.bodySmall),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Agent B: Recruiter Mirror
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.shield_outlined, color: AppColors.primary, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  "Agent B: Recruiter Mirror",
                                  style: AppTypography.titleSmall.copyWith(color: AppColors.primary),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(_evaluation!.recruiterSummary, style: AppTypography.bodySmall),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Key Strengths
                      Text("Key Strengths", style: AppTypography.titleMedium),
                      const SizedBox(height: 10),
                      ..._evaluation!.keyStrengths.map(
                        (s) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.check_circle_rounded, color: AppColors.emerald, size: 18),
                              const SizedBox(width: 10),
                              Expanded(child: Text(s, style: AppTypography.bodyMedium)),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Identified Skill Gaps
                      Text("Identified Skill Gaps", style: AppTypography.titleMedium),
                      const SizedBox(height: 10),
                      ..._evaluation!.identifiedGaps.map(
                        (g) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.warning_amber_rounded, color: AppColors.amber, size: 18),
                              const SizedBox(width: 10),
                              Expanded(child: Text(g, style: AppTypography.bodyMedium)),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
