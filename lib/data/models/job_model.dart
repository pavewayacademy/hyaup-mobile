class JobModel {
  final String id;
  final String title;
  final String company;
  final String location;
  final String description;
  final String sourceType; // 'native' or 'external'
  final String? externalApplyUrl;
  final num? salaryMin;
  final num? salaryMax;
  final String currency;
  final bool hasPaidPto;
  final bool hasHealthCoverage;
  final String remoteMode; // 'remote', 'hybrid', 'onsite'
  final List<String> requiredSkills;
  final double? matchScore; // 0.0 to 1.0 (e.g. 0.85 = 85%)
  final DateTime postedAt;

  JobModel({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.description,
    required this.sourceType,
    this.externalApplyUrl,
    this.salaryMin,
    this.salaryMax,
    this.currency = "XAF",
    this.hasPaidPto = false,
    this.hasHealthCoverage = false,
    this.remoteMode = "onsite",
    this.requiredSkills = const [],
    this.matchScore,
    DateTime? postedAt,
  }) : postedAt = postedAt ?? DateTime.now();

  bool get isNative => sourceType.toLowerCase() == 'native';
  bool get isExternal => !isNative;

  int? get matchPercentage => matchScore != null ? (matchScore! * 100).round() : null;

  factory JobModel.fromJson(Map<String, dynamic> json) {
    // Handle nested benefits JSONB if present from backend
    final benefits = json['benefits'] is Map ? json['benefits'] as Map<String, dynamic> : <String, dynamic>{};

    // Parse required skills
    List<String> skills = [];
    if (json['required_skills'] is List) {
      skills = (json['required_skills'] as List).map((e) => e.toString()).toList();
    } else if (json['skills'] is List) {
      skills = (json['skills'] as List).map((e) => e.toString()).toList();
    }

    return JobModel(
      id: (json['id'] ?? json['_id'] ?? DateTime.now().millisecondsSinceEpoch).toString(),
      title: json['title'] ?? json['job_title'] ?? 'Untitled Opportunity',
      company: json['company'] ?? json['organization'] ?? json['company_name'] ?? 'Company Confidential',
      location: json['location'] ?? json['city'] ?? 'Cameroon',
      description: json['description'] ?? json['content'] ?? '',
      sourceType: json['source_type'] ?? (json['url'] != null ? 'external' : 'native'),
      externalApplyUrl: json['external_apply_url'] ?? json['url'],
      salaryMin: json['salary_min'] ?? json['min_salary'],
      salaryMax: json['salary_max'] ?? json['max_salary'],
      currency: json['currency'] ?? "XAF",
      hasPaidPto: json['has_paid_pto'] ?? benefits['paid_pto'] ?? false,
      hasHealthCoverage: json['has_health_coverage'] ?? benefits['health_coverage'] ?? false,
      remoteMode: json['remote_mode'] ?? benefits['remote_mode'] ?? 'onsite',
      requiredSkills: skills,
      matchScore: json['compatibility_score'] != null 
          ? (json['compatibility_score'] as num).toDouble() 
          : (json['match_score'] != null ? (json['match_score'] as num).toDouble() : null),
      postedAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now() 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'company': company,
      'location': location,
      'description': description,
      'source_type': sourceType,
      'external_apply_url': externalApplyUrl,
      'salary_min': salaryMin,
      'salary_max': salaryMax,
      'currency': currency,
      'benefits': {
        'paid_pto': hasPaidPto,
        'health_coverage': hasHealthCoverage,
        'remote_mode': remoteMode,
      },
      'required_skills': requiredSkills,
      'compatibility_score': matchScore,
      'created_at': postedAt.toIso8601String(),
    };
  }
}
