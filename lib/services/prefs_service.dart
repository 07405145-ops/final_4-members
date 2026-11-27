import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> saveLogin({
    required String email,
    required String name,
    required String uid,
  }) async {
    await _prefs?.setString('user_email', email);
    await _prefs?.setString('user_name', name);
    await _prefs?.setString('user_uid', uid);
    await _prefs?.setBool('is_logged_in', true);
  }

  static Future<void> clearLogin() async {
    await _prefs?.remove('user_email');
    await _prefs?.remove('user_name');
    await _prefs?.remove('user_uid');
    await _prefs?.setBool('is_logged_in', false);
  }

  static String? get email => _prefs?.getString('user_email');
  static String? get name => _prefs?.getString('user_name');
  static String? get uid => _prefs?.getString('user_uid');
  static bool get isLoggedIn => _prefs?.getBool('is_logged_in') ?? false;
}