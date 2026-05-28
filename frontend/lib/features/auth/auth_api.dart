import 'dart:convert';
import 'dart:typed_data';

import 'package:shared_preferences/shared_preferences.dart';

class AuthApi {
  AuthApi._();

  static const String _usernameKey = 'saved_username';
  static const String _passwordKey = 'saved_password';
  static const String _nameKey = 'saved_name';
  static const String _loginKey = 'is_logged_in';
  static const String _avatarKey = 'saved_avatar';

  static Future<bool> register({
    required String name,
    required String username,
    required String password,
    Uint8List? avatarBytes,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (name.isEmpty || username.length < 4 || password.length < 4) {
      return false;
    }

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_nameKey, name);
    await prefs.setString(_usernameKey, username);
    await prefs.setString(_passwordKey, password);

    if (avatarBytes != null) {
      await prefs.setString(_avatarKey, base64Encode(avatarBytes));
    }

    return true;
  }

  static Future<bool> login({
    required String username,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final prefs = await SharedPreferences.getInstance();

    final savedUsername = prefs.getString(_usernameKey);
    final savedPassword = prefs.getString(_passwordKey);

    final success = username == savedUsername && password == savedPassword;

    if (success) {
      await prefs.setBool(_loginKey, true);
    }

    return success;
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_loginKey) ?? false;
  }

  static Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_nameKey) ?? '나';
  }

  static Future<Uint8List?> getAvatarBytes() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_avatarKey);

    if (raw == null || raw.isEmpty) return null;

    return base64Decode(raw);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loginKey, false);
  }
}