import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Service lưu thông tin đăng nhập (email + mật khẩu) vào SharedPreferences
/// Mật khẩu được encode Base64 — đủ dùng cho app sinh viên
/// Production: nên dùng flutter_secure_storage để mã hóa AES
class SavedCredentialsService {
  SavedCredentialsService._();

  static const _keyEmail    = 'saved_email';
  static const _keyPassword = 'saved_password'; // Base64 encoded
  static const _keyRemember = 'remember_login';
  static const _keyRole     = 'saved_role_index';

  /// Lưu thông tin đăng nhập
  static Future<void> save({
    required String email,
    required String password,
    required int roleIndex,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyEmail, email);
    // Encode Base64 để không lộ rõ plaintext trong file preferences
    await prefs.setString(_keyPassword, base64.encode(utf8.encode(password)));
    await prefs.setBool(_keyRemember, true);
    await prefs.setInt(_keyRole, roleIndex);
  }

  /// Xóa thông tin đã lưu (khi bỏ tick "Ghi nhớ")
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyPassword);
    await prefs.setBool(_keyRemember, false);
    await prefs.remove(_keyRole);
  }

  /// Lấy email đã lưu
  static Future<String?> getSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEmail);
  }

  /// Lấy mật khẩu đã lưu (giải mã Base64)
  static Future<String?> getSavedPassword() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getString(_keyPassword);
    if (encoded == null) return null;
    try {
      return utf8.decode(base64.decode(encoded));
    } catch (_) {
      return null;
    }
  }

  /// Lấy role index đã lưu (0=HTX, 1=Buyer)
  static Future<int> getSavedRoleIndex() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyRole) ?? 0;
  }

  /// Kiểm tra xem có lưu thông tin không
  static Future<bool> isRemembered() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyRemember) ?? false;
  }
}
