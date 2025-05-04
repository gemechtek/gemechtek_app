import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:spark_aquanix/backend/model/user_model.dart';

class LocalPreferenceService {
  static final LocalPreferenceService _instance =
      LocalPreferenceService._internal();
  factory LocalPreferenceService() => _instance;
  LocalPreferenceService._internal();

  static SharedPreferences? _prefs;

  Future<SharedPreferences> get _sharedPrefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  static const String _keyUser = 'user_data';
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyThemeMode = 'theme_mode';

  Future<void> saveUserData(UserModel user) async {
    final prefs = await _sharedPrefs;
    await prefs.setString(_keyUser, jsonEncode(user.toMap()));
    await prefs.setBool(_keyIsLoggedIn, true);
  }

  Future<UserModel?> getUserData() async {
    final prefs = await _sharedPrefs;
    final String? userStr = prefs.getString(_keyUser);
    if (userStr != null) {
      return UserModel.fromMap(jsonDecode(userStr));
    }
    return null;
  }

  Future<bool> isLoggedIn() async {
    final prefs = await _sharedPrefs;
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  Future<void> clearUserData() async {
    final prefs = await _sharedPrefs;
    await prefs.remove(_keyUser);
    await prefs.setBool(_keyIsLoggedIn, false);
  }

  Future<void> updateUserData(UserModel updatedUser) async {
    final currentUser = await getUserData();
    if (currentUser != null) {
      final newUser = currentUser.copyWith(
        name: updatedUser.name,
        phone: updatedUser.phone,
        address: updatedUser.address,
        fcmToken: updatedUser.fcmToken,
      );
      await saveUserData(newUser);
    }
  }

  Future<void> setThemeMode(String mode) async {
    final prefs = await _sharedPrefs;
    await prefs.setString(_keyThemeMode, mode);
  }

  Future<String> getThemeMode() async {
    final prefs = await _sharedPrefs;
    return prefs.getString(_keyThemeMode) ?? "light";
  }
}
