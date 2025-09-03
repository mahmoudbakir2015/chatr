import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const String _key = "user_token";

  // 🟢 حفظ الـ token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, token);
  }

  // 🟢 استرجاع الـ token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  // 🟢 مسح الـ token
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
