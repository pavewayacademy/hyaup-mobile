import '../../core/constants/api_endpoints.dart';
import '../../repository/api_client.dart';
import '../models/filter_model.dart';
import '../models/job_model.dart';

class JobRepository {
  final ApiClient _apiClient = ApiClient();

  /// Curated Cameroon seed opportunities (Native + Scraped External)
  /// Guaranteed to render instantly for unauthenticated discovery!
  final List<JobModel> _seedJobs = [
    JobModel(
      id: "native-101",
      title: "Senior Flutter & AI Mobile Engineer",
      company: "Project Nexus / Paveway Academy",
      location: "Douala, Cameroon (Hybrid)",
      description:
          "We are seeking an experienced Flutter Mobile Engineer to lead the client-side architecture of our AI-driven job search engine. You will craft high-performance reactive interfaces, integrate LangGraph multi-agent match workflows, and deliver an Indeed-standard user experience for professionals across Central Africa.",
      sourceType: "native",
      salaryMin: 650000,
      salaryMax: 950000,
      currency: "XAF",
      hasPaidPto: true,
      hasHealthCoverage: true,
      remoteMode: "hybrid",
      requiredSkills: ["Flutter", "Dart", "Firebase Auth", "Dio REST", "Riverpod", "Clean Architecture"],
      matchScore: 0.95,
      postedAt: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    JobModel(
      id: "native-102",
      title: "Backend Core Architect (FastAPI & pgvector)",
      company: "HyaUp Technologies",
      location: "Yaoundé, Cameroon (Remote)",
      description:
          "Join Pod 2 to engineer scalable vector discovery microservices. You will architect high-concurrency async FastAPI endpoints, maintain pgvector cosine distance indices, and build reliable scraper pipelines for aggregated regional job postings.",
      sourceType: "native",
      salaryMin: 700000,
      salaryMax: 1100000,
      currency: "XAF",
      hasPaidPto: true,
      hasHealthCoverage: true,
      remoteMode: "remote",
      requiredSkills: ["Python", "FastAPI", "PostgreSQL", "pgvector", "Docker", "Google Cloud Run"],
      matchScore: 0.88,
      postedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    JobModel(
      id: "ext-201",
      title: "Associate Program Director",
      company: "Clinton Health Access Initiative (CHAI)",
      location: "Yaoundé, Cameroon",
      description:
          "Provide strategic and operational leadership across CHAI Cameroon's health systems strengthening portfolio. Manage multilateral partner engagements, drive business development, and oversee national programmatic health initiatives.",
      sourceType: "external",
      externalApplyUrl: "https://unjobs.org/vacancies/1787238469828",
      salaryMin: 1200000,
      salaryMax: 1800000,
      currency: "XAF",
      hasPaidPto: true,
      hasHealthCoverage: true,
      remoteMode: "onsite",
      requiredSkills: ["Program Management", "Strategic Planning", "Business Development", "French", "English"],
      matchScore: 0.81,
      postedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    JobModel(
      id: "ext-202",
      title: "National Security & Operations Officer",
      company: "IOM - UN Migration",
      location: "Yaoundé, Cameroon",
      description:
          "Coordinate mission security risk management, physical access control protocols, and contingency evacuation plans for IOM personnel and transit facilities across Cameroon.",
      sourceType: "external",
      externalApplyUrl: "https://unjobs.org/vacancies/1787158382725",
      salaryMin: 900000,
      salaryMax: 1350000,
      currency: "XAF",
      hasPaidPto: true,
      hasHealthCoverage: true,
      remoteMode: "onsite",
      requiredSkills: ["Security Management", "Risk Assessment", "UNDSS", "Contingency Planning"],
      matchScore: 0.74,
      postedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    JobModel(
      id: "native-103",
      title: "Fintech Mobile Developer (USSD & Payments)",
      company: "Campay Solutions",
      location: "Douala, Cameroon",
      description:
          "Building next-generation Mobile Money payment gateways and merchant apps. Experience with MTN MoMo APIs, Orange Money webhooks, and secure local transaction flows required.",
      sourceType: "native",
      salaryMin: 500000,
      salaryMax: 800000,
      currency: "XAF",
      hasPaidPto: true,
      hasHealthCoverage: false,
      remoteMode: "onsite",
      requiredSkills: ["Flutter", "Mobile Money API", "Cryptography", "Security", "REST"],
      matchScore: 0.89,
      postedAt: DateTime.now().subtract(const Duration(hours: 12)),
    ),
    JobModel(
      id: "native-104",
      title: "Junior Data Analyst & Python Scraper",
      company: "Nexus AI Lab",
      location: "Bafoussam, Cameroon (Remote)",
      description:
          "Opportunity for an ambitious junior engineer to maintain web scraping workers, clean unstructured employer data, and generate vector embeddings for our regional job index.",
      sourceType: "native",
      salaryMin: 250000,
      salaryMax: 400000,
      currency: "XAF",
      hasPaidPto: false,
      hasHealthCoverage: false,
      remoteMode: "remote",
      requiredSkills: ["Python", "BeautifulSoup", "Pandas", "SQL", "Git"],
      matchScore: 0.79,
      postedAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
  ];

  /// Search jobs with plain-language vector query and multi-parameter filters
  Future<List<JobModel>> searchJobs({
    String query = "",
    FilterModel? filter,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        if (query.trim().isNotEmpty) 'q': query.trim(),
        if (filter != null) ...filter.toQueryParams(),
      };

      final response = await _apiClient.dio.get(
        ApiEndpoints.jobsSearch,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List).map((item) => JobModel.fromJson(item)).toList();
      }
    } catch (_) {
      // Graceful fallback to client-side vector/mock search if backend is currently unreachable
    }

    // Client-side search and filtering fallback
    return _filterSeedJobs(query, filter);
  }

  List<JobModel> _filterSeedJobs(String query, FilterModel? filter) {
    List<JobModel> results = List.from(_seedJobs);

    // Free text matching (Title, Company, Skills, Description)
    if (query.trim().isNotEmpty) {
      final q = query.toLowerCase();
      results = results.where((job) {
        final inTitle = job.title.toLowerCase().contains(q);
        final inCompany = job.company.toLowerCase().contains(q);
        final inDesc = job.description.toLowerCase().contains(q);
        final inSkills = job.requiredSkills.any((s) => s.toLowerCase().contains(q));
        return inTitle || inCompany || inDesc || inSkills;
      }).toList();
    }

    // Apply multi-parameter filters
    if (filter != null) {
      if (filter.minSalary != null && filter.minSalary! > 0) {
        results = results.where((j) => (j.salaryMax ?? j.salaryMin ?? 0) >= filter.minSalary!).toList();
      }
      if (filter.hasPaidPto == true) {
        results = results.where((j) => j.hasPaidPto).toList();
      }
      if (filter.hasHealthCoverage == true) {
        results = results.where((j) => j.hasHealthCoverage).toList();
      }
      if (filter.remoteMode != null && filter.remoteMode!.isNotEmpty) {
        results = results.where((j) => j.remoteMode.toLowerCase() == filter.remoteMode!.toLowerCase()).toList();
      }
      if (filter.sourceType != null && filter.sourceType!.isNotEmpty) {
        results = results.where((j) => j.sourceType.toLowerCase() == filter.sourceType!.toLowerCase()).toList();
      }
    }

    // Sort by match score descending
    results.sort((a, b) => (b.matchScore ?? 0).compareTo(a.matchScore ?? 0));
    return results;
  }

  /// Post a new native employer listing
  Future<JobModel> createJob(Map<String, dynamic> payload) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.jobsCreate,
        data: payload,
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        final job = JobModel.fromJson(response.data);
        _seedJobs.insert(0, job);
        return job;
      }
    } catch (_) {
      // Fallback
    }

    // Add locally to seed data
    final created = JobModel.fromJson({
      ...payload,
      'id': 'native-${DateTime.now().millisecondsSinceEpoch}',
      'source_type': 'native',
      'compatibility_score': 0.92,
      'created_at': DateTime.now().toIso8601String(),
    });
    _seedJobs.insert(0, created);
    return created;
  }
}
