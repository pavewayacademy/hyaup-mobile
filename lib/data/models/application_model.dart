class ApplicationModel {
  final String id;
  final String jobId;
  final String jobTitle;
  final String companyName;
  final String location;
  final String sourceType; // 'native' or 'external'
  final String status; // 'submitted', 'in_review', 'external_redirect', 'saved'
  final DateTime timestamp;
  final String? externalUrl;

  ApplicationModel({
    required this.id,
    required this.jobId,
    required this.jobTitle,
    required this.companyName,
    required this.location,
    required this.sourceType,
    required this.status,
    required this.timestamp,
    this.externalUrl,
  });

  bool get isSubmitted => status.toLowerCase() == 'submitted';
  bool get isExternalRedirect => status.toLowerCase() == 'external_redirect';
  bool get isSaved => status.toLowerCase() == 'saved';

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    return ApplicationModel(
      id: (json['id'] ?? DateTime.now().millisecondsSinceEpoch).toString(),
      jobId: (json['job_id'] ?? '').toString(),
      jobTitle: json['job_title'] ?? 'Software Opportunity',
      companyName: json['company_name'] ?? 'Enterprise Employer',
      location: json['location'] ?? 'Cameroon',
      sourceType: json['source_type'] ?? 'native',
      status: json['status'] ?? 'submitted',
      timestamp: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
      externalUrl: json['external_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'job_id': jobId,
      'job_title': jobTitle,
      'company_name': companyName,
      'location': location,
      'source_type': sourceType,
      'status': status,
      'created_at': timestamp.toIso8601String(),
      'external_url': externalUrl,
    };
  }
}
