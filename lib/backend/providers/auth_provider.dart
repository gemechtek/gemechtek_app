// lib/providers/auth_provider.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:gemechtek_app/backend/services/auth_service.dart';
import '../model/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuthService _authService = FirebaseAuthService();
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _verificationId;
  String? _error;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  String? get error => _error;
  String? get verificationId => _verificationId; // Added getter for UI access

  AuthProvider() {
    // _authService.currentUser.listen((user) {
    //   _currentUser = user;
    //   notifyListeners();
    //   if (user != null) {
    //     _updateFcmToken();
    //   }
    // });
  }

  // Send OTP (with login or registration context)
  Future<bool> sendOTP(String phoneNumber, {required bool isLogin}) async {
    try {
      _setLoading(true);
      _error = null;

      _verificationId =
          await _authService.sendOTP(phoneNumber, isLogin: isLogin);
      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Verify OTP and complete registration
  Future<bool> verifyOTPAndRegister(
      String otp, String name, String phone) async {
    if (_verificationId == null) return false;

    try {
      _setLoading(true);
      _error = null;

      final UserCredential credential =
          await _authService.verifyOTP(_verificationId!, otp);

      final String fcmToken = await _getFcmToken();

      await _authService.createOrUpdateUser(
        uid: credential.user!.uid,
        name: name,
        phone: phone,
        fcmToken: fcmToken,
      );

      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Verify OTP and login
  Future<bool> verifyOTPAndLogin(String otp, String phone) async {
    if (_verificationId == null) return false;

    try {
      _setLoading(true);
      _error = null;

      final UserCredential credential =
          await _authService.verifyOTP(_verificationId!, otp);

      if (credential.user != null) {
        final String fcmToken = await _getFcmToken();
        final user = await _authService.getUserData(credential.user!.uid);

        if (user != null && user.fcmToken != fcmToken) {
          await _authService.createOrUpdateUser(
            uid: user.id,
            name: user.name,
            phone: user.phone,
            address: user.address,
            fcmToken: fcmToken,
          );
        }
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Update user details
  Future<bool> updateUserDetails({String? name, String? address}) async {
    if (_currentUser == null) return false;

    try {
      _setLoading(true);
      _error = null;

      await _authService.createOrUpdateUser(
        uid: _currentUser!.id,
        name: name ?? _currentUser!.name,
        phone: _currentUser!.phone,
        address: address ?? _currentUser!.address,
        fcmToken: _currentUser!.fcmToken,
      );

      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _error = e.toString();
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    _setLoading(true);
    await _authService.signOut();
    _currentUser = null;
    _setLoading(false);
    notifyListeners();
  }

  // Get FCM token
  Future<String> _getFcmToken() async {
    try {
      return await FirebaseMessaging.instance.getToken() ?? '';
    } catch (e) {
      print('Error getting FCM token: ${e.toString()}');
      return '';
    }
  }

  // Update FCM token
  Future<void> _updateFcmToken() async {
    if (_currentUser != null) {
      final String token = await _getFcmToken();
      if (token != _currentUser!.fcmToken) {
        await _authService.createOrUpdateUser(
          uid: _currentUser!.id,
          name: _currentUser!.name,
          phone: _currentUser!.phone,
          address: _currentUser!.address,
          fcmToken: token,
        );
      }
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setErrorMessage(String? message) {
    _error = message;
    notifyListeners();
  }
}
