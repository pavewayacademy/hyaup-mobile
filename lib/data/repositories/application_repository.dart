import '../../core/constants/api_endpoints.dart';
import '../../repository/api_client.dart';
import '../models/application_model.dart';
import '../models/job_model.dart';

class ApplicationRepository {
  static final ApplicationRepository _instance = ApplicationRepository._internal();
  factory ApplicationRepository() => _instance;

  final ApiClient _apiClient = ApiClient();

  // In-memory cache of applications and saved bookmarks
  final List<ApplicationModel> _applications = [];
  final Set<String> _bookmarkedJobIds = {};

  ApplicationRepository._internal() {
    // Seed initial application items for demonstration
    _applications.addAll([
      ApplicationModel(
        id: "app-1",
        jobId: "native-101",
        jobTitle: "Senior Flutter & AI Mobile Engineer",
        companyName: "Project Nexus / Paveway Academy",
        location: "Douala, Cameroon",
        sourceType: "native",
        status: "submitted",
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
      ),
      ApplicationModel(
        id: "app-2",
        jobId: "ext-201",
        jobTitle: "Associate Program Director",
        companyName: "Clinton Health Access Initiative (CHAI)",
        location: "Yaoundé, Cameroon",
        sourceType: "external",
        status: "external_redirect",
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        externalUrl: "https://unjobs.org/vacancies/1787238469828",
      ),
    ]);
    _bookmarkedJobIds.add("native-102");
  }

  List<ApplicationModel> getApplications() {
    return List.unmodifiable(_applications);
  }

  bool isJobBookmarked(String jobId) {
    return _bookmarkedJobIds.contains(jobId);
  }

  void toggleBookmark(JobModel job) {
    if (_bookmarkedJobIds.contains(job.id)) {
      _bookmarkedJobIds.remove(job.id);
      _applications.removeWhere((a) => a.jobId == job.id && a.status == "saved");
    } else {
      _bookmarkedJobIds.add(job.id);
      _applications.insert(
        0,
        ApplicationModel(
          id: "save-${DateTime.now().millisecondsSinceEpoch}",
          jobId: job.id,
          jobTitle: job.title,
          companyName: job.company,
          location: job.location,
          sourceType: job.sourceType,
          status: "saved",
          timestamp: DateTime.now(),
          externalUrl: job.externalApplyUrl,
        ),
      );
    }
  }

  /// Submit 1-Click application for native postings
  Future<ApplicationModel> submitNativeApplication(JobModel job) async {
    try {
      await _apiClient.dio.post(
        ApiEndpoints.applications,
        data: {
          'job_id': job.id,
          'job_title': job.title,
          'company_name': job.company,
          'source_type': 'native',
        },
      );
    } catch (_) {
      // Offline fallback
    }

    final newApp = ApplicationModel(
      id: "app-${DateTime.now().millisecondsSinceEpoch}",
      jobId: job.id,
      jobTitle: job.title,
      companyName: job.company,
      location: job.location,
      sourceType: "native",
      status: "submitted",
      timestamp: DateTime.now(),
    );

    _applications.insert(0, newApp);
    return newApp;
  }

  /// Track external job redirect telemetry
  Future<ApplicationModel> trackExternalRedirect(JobModel job) async {
    try {
      await _apiClient.dio.post(
        ApiEndpoints.trackRedirect,
        data: {
          'job_id': job.id,
          'external_url': job.externalApplyUrl,
          'company_name': job.company,
          'job_title': job.title,
        },
      );
    } catch (_) {
      // Offline fallback
    }

    final newRedirect = ApplicationModel(
      id: "red-${DateTime.now().millisecondsSinceEpoch}",
      jobId: job.id,
      jobTitle: job.title,
      companyName: job.company,
      location: job.location,
      sourceType: "external",
      status: "external_redirect",
      timestamp: DateTime.now(),
      externalUrl: job.externalApplyUrl,
    );

    _applications.insert(0, newRedirect);
    return newRedirect;
  }
}
