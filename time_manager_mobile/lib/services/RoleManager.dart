import 'package:shared_preferences/shared_preferences.dart';

class RoleManager {
  static const String _roleKey = 'userRole';

  static Future<void> saveUserRole(String userRole) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_roleKey, userRole);
  }

  static Future<String?> getUserRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_roleKey);
  }

  static Future<void> clearUserRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_roleKey);
  }
}