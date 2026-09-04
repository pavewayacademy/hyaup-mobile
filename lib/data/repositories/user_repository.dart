import '../../core/constants/api_endpoints.dart';
import '../../core/utils/app_preferences.dart';
import '../../repository/api_client.dart';

class UserRepository {
  static final UserRepository _instance = UserRepository._internal();
  factory UserRepository() => _instance;

  final ApiClient _apiClient = ApiClient();

  // In-memory profile cache
  Map<String, dynamic>? _cachedProfile;

  UserRepository._internal();

  Map<String, dynamic>? get currentProfile => _cachedProfile;

  /// Sync user account and onboarding details to FastAPI backend
  Future<Map<String, dynamic>> saveOnboardingProfile({
    required String uid,
    required String email,
    required String role, // 'employer' or 'professional'
    required Map<String, dynamic> onboardingData,
  }) async {
    final payload = {
      'uid': uid,
      'email': email,
      'role': role,
      ...onboardingData,
    };

    try {
      final response = await _apiClient.dio.patch(
        "${ApiEndpoints.users}/$uid",
        data: payload,
      );

      if (response.statusCode == 200 && response.data is Map) {
        _cachedProfile = Map<String, dynamic>.from(response.data);
      }
    } catch (_) {
      // Fallback to local profile cache
      _cachedProfile = payload;
    }

    _cachedProfile ??= payload;
    await AppPreferences.setUserRole(role);
    await AppPreferences.setOnboarded(true);

    return _cachedProfile!;
  }

  /// Pull user profile information from the backend
  Future<Map<String, dynamic>?> fetchUserProfile(String uid) async {
    try {
      final response = await _apiClient.dio.get("${ApiEndpoints.users}/$uid");
      if (response.statusCode == 200 && response.data is Map) {
        _cachedProfile = Map<String, dynamic>.from(response.data);
        return _cachedProfile;
      }
    } catch (_) {
      // Fallback
    }

    return _cachedProfile;
  }

  void clearCache() {
    _cachedProfile = null;
  }
}
