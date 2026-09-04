class AiMatchModel {
  final String jobId;
  final int matchPercentage; // 0 to 100
  final String advocateSummary; // Candidate Advocate synthesis
  final String recruiterSummary; // Recruiter Mirror evaluation
  final List<String> keyStrengths;
  final List<String> identifiedGaps;
  final List<String> actionableAdvice;

  AiMatchModel({
    required this.jobId,
    required this.matchPercentage,
    required this.advocateSummary,
    required this.recruiterSummary,
    required this.keyStrengths,
    required this.identifiedGaps,
    required this.actionableAdvice,
  });

  factory AiMatchModel.fromJson(Map<String, dynamic> json) {
    return AiMatchModel(
      jobId: (json['job_id'] ?? '').toString(),
      matchPercentage: ((json['match_score'] ?? json['compatibility_score'] ?? 0.75) is num)
          ? ((json['match_score'] ?? json['compatibility_score']) as num > 1
              ? (json['match_score'] ?? json['compatibility_score'] as num).toInt()
              : ((json['match_score'] ?? json['compatibility_score'] as num) * 100).round())
          : 75,
      advocateSummary: json['advocate_summary'] ??
          "Your demonstrated background in modern development frameworks and modular architectures aligns closely with the core objectives of this role.",
      recruiterSummary: json['recruiter_summary'] ??
          "The hiring team requires verified delivery experience and production pipeline management within high-velocity teams in Cameroon.",
      keyStrengths: (json['key_strengths'] as List?)?.map((e) => e.toString()).toList() ?? [
        "Strong alignment in state management and reactive programming",
        "Direct experience with REST API integration and token authentication",
        "Demonstrated track record of delivering user-centric mobile workflows",
      ],
      identifiedGaps: (json['identified_gaps'] as List?)?.map((e) => e.toString()).toList() ?? [
        "Familiarity with localized Cameroon telecom USSD / payment gateways",
        "Experience running automated end-to-end integration tests in CI/CD",
      ],
      actionableAdvice: (json['actionable_advice'] as List?)?.map((e) => e.toString()).toList() ?? [
        "Highlight any prior portfolio apps deployed to the Google Play Store or TestFlight.",
        "Emphasize experience collaborating across asynchronous engineering teams.",
      ],
    );
  }
}
