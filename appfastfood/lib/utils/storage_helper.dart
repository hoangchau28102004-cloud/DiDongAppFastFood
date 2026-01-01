import 'package:shared_preferences/shared_preferences.dart';

class StorageHelper {
  static const String _token = 'token';

  static Future<void> init() async {
    await SharedPreferences.getInstance();
  }

  static Future<void> saveToke(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_token, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_token);
  }
}
