import 'package:shared_preferences/shared_preferences.dart';

class SharePrefService {
  static SharePrefService? _instance;
  static SharePrefService get instance => _instance ??= SharePrefService._();

  SharePrefService._();

  // Save user ID
  Future<void> addUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
  }

  // Get saved user ID
  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  // Remmeber Me
  Future rememberMe(bool remeberMe) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setBool('remeber_me', remeberMe);
  }
 

  // Clear saved user ID
  Future<void> clearUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
  }

}