import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static const String _keyHasSeenIntro = "has_seen_intro";
  static const String _keyUserRole = "user_role"; // 'employer' or 'professional'
  static const String _keyIsOnboarded = "is_onboarded";

  static Future<bool> hasSeenIntro() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyHasSeenIntro) ?? false;
  }

  static Future<void> setHasSeenIntro(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHasSeenIntro, value);
  }

  static Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserRole);
  }

  static Future<void> setUserRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserRole, role);
  }

  static Future<bool> isOnboarded() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsOnboarded) ?? false;
  }

  static Future<void> setOnboarded(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsOnboarded, value);
  }

  static Future<void> clearPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyHasSeenIntro);
    await prefs.remove(_keyUserRole);
    await prefs.remove(_keyIsOnboarded);
  }
}
