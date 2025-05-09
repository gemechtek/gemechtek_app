import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spark_aquanix/backend/model/order_model.dart';
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
  static const String _keySavedAddresses = 'saved_addresses';

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

  // Address management functions
  Future<List<DeliveryAddress>> getSavedAddresses() async {
    final prefs = await _sharedPrefs;
    final String? addressesJson = prefs.getString(_keySavedAddresses);
    if (addressesJson != null && addressesJson.isNotEmpty) {
      final List<dynamic> decoded = jsonDecode(addressesJson);
      return decoded.map((addr) => DeliveryAddress.fromMap(addr)).toList();
    }
    return [];
  }

  Future<void> saveAddress(DeliveryAddress address) async {
    final addresses = await getSavedAddresses();

    // Check if the address already exists by ID
    final existingIndex = addresses.indexWhere((a) => a.id == address.id);

    if (existingIndex >= 0) {
      // Update existing address
      addresses[existingIndex] = address;
    } else {
      // Add new address
      addresses.add(address);
    }

    // If this is a default address, update other addresses
    if (address.isDefault) {
      for (int i = 0; i < addresses.length; i++) {
        if (addresses[i].id != address.id && addresses[i].isDefault) {
          addresses[i] = addresses[i].copyWith(isDefault: false);
        }
      }
    }

    await _saveAddressList(addresses);
  }

  Future<void> _saveAddressList(List<DeliveryAddress> addresses) async {
    final prefs = await _sharedPrefs;
    final encodedList = addresses.map((addr) => addr.toMap()).toList();
    await prefs.setString(_keySavedAddresses, jsonEncode(encodedList));
  }

  Future<void> deleteAddress(String addressId) async {
    final addresses = await getSavedAddresses();
    addresses.removeWhere((address) => address.id == addressId);
    await _saveAddressList(addresses);
  }

  Future<void> setDefaultAddress(String addressId) async {
    final addresses = await getSavedAddresses();
    for (int i = 0; i < addresses.length; i++) {
      if (addresses[i].id == addressId) {
        addresses[i] = addresses[i].copyWith(isDefault: true);
      } else if (addresses[i].isDefault) {
        addresses[i] = addresses[i].copyWith(isDefault: false);
      }
    }
    await _saveAddressList(addresses);
  }

  Future<DeliveryAddress?> getDefaultAddress() async {
    final addresses = await getSavedAddresses();
    return addresses.firstWhere((address) => address.isDefault,
        orElse: () => addresses.first);
  }
}
