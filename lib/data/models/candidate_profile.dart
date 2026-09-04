class CandidateProfile {
  final String id;
  final String email;
  final String fullName;
  final String? headline;
  final List<String> skills;
  final String? resumeFilename;
  final bool hasVectorProfile;

  CandidateProfile({
    required this.id,
    required this.email,
    required this.fullName,
    this.headline,
    this.skills = const [],
    this.resumeFilename,
    this.hasVectorProfile = false,
  });

  factory CandidateProfile.fromJson(Map<String, dynamic> json) {
    return CandidateProfile(
      id: (json['id'] ?? json['uid'] ?? '').toString(),
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? json['name'] ?? 'HyaUp Professional',
      headline: json['headline'] ?? 'Mobile & AI Specialist',
      skills: (json['skills'] as List?)?.map((e) => e.toString()).toList() ?? [],
      resumeFilename: json['resume_filename'],
      hasVectorProfile: json['has_vector_profile'] ?? false,
    );
  }
}
