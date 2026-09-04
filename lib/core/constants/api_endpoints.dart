class ApiEndpoints {
  // Configurable base URL (default local FastAPI server)
  // For Android Emulator use 10.0.2.2, for iOS/Desktop use localhost/127.0.0.1
  static const String defaultBaseUrl = "http://10.0.2.2:8000";

  // Job Search & Management
  static const String jobsSearch = "/jobs/search";
  static const String jobsCreate = "/jobs/create";
  static const String jobsDetails = "/jobs"; // /jobs/{id}

  // Onboarding & Resume Ingestion
  static const String resumeUpload = "/onboard/resume-upload";
  static const String candidateProfile = "/candidates/me";

  // LangGraph AI Match Engine
  static const String aiMatchEvaluate = "/match/evaluate";
  static const String aiCareerChat = "/agent/chat";

  // Applications & Pipeline Telemetry
  static const String applications = "/applications";
  static const String trackRedirect = "/applications/track-redirect";

  // User Management & Onboarding
  static const String users = "/users";
  static const String userOnboarding = "/users/onboarding";
}
