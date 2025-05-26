// lib/providers/auth_provider.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:spark_aquanix/backend/firebase_services/auth_service.dart';
import 'package:spark_aquanix/constants/error_formatter.dart';
import '../model/user_model.dart';

enum AuthMethod { phone, email, google }

class AuthProvider extends ChangeNotifier {
  final FirebaseAuthService _authService = FirebaseAuthService();
  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isGLoading = false;
  String? _verificationId;
  String? _error;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isGLoading => _isGLoading;

  bool get isAuthenticated => _currentUser != null;
  String? get error => _error;
  String? get verificationId => _verificationId;

  AuthProvider() {
    _isLoading = true;
    notifyListeners();
    _authService.currentUser.listen((user) {
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      if (user != null) {
        _updateFcmToken();
      }
    });
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
      _error = ErrorFormatter.formatAuthError(e);
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
        email: credential.user!.email,
        fcmToken: fcmToken,
      );

      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _error = ErrorFormatter.formatAuthError(e);
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
            email: user.email,
            address: user.address,
            fcmToken: fcmToken,
          );
        }
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _error = ErrorFormatter.formatAuthError(e);
      notifyListeners();
      return false;
    }
  }

  // Email Sign Up
  Future<bool> signUpWithEmail(
      String email, String password, String name) async {
    try {
      _setLoading(true);
      _error = null;

      final UserCredential credential =
          await _authService.signUpWithEmail(email, password);
      final String fcmToken = await _getFcmToken();

      await _authService.createOrUpdateUser(
        uid: credential.user!.uid,
        name: name,
        email: email,
        phone: '',
        fcmToken: fcmToken,
      );
      _authService.saveUserDataToLocal(
        UserModel(
          id: credential.user!.uid,
          name: name,
          phone: '',
          email: email,
          fcmToken: fcmToken,
        ),
      );
      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _error = ErrorFormatter.formatAuthError(e);
      notifyListeners();
      return false;
    }
  }

  // Email Sign In
  Future<bool> signInWithEmail(String email, String password) async {
    try {
      _setLoading(true);
      _error = null;

      final UserCredential credential =
          await _authService.signInWithEmail(email, password);

      if (credential.user != null) {
        final String fcmToken = await _getFcmToken();
        final user = await _authService.getUserData(credential.user!.uid);

        if (user != null && user.fcmToken != fcmToken) {
          await _authService.createOrUpdateUser(
            uid: user.id,
            name: user.name,
            phone: user.phone,
            email: user.email,
            address: user.address,
            fcmToken: fcmToken,
          );
        }
        _authService.saveUserDataToLocal(user!);
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _error = ErrorFormatter.formatAuthError(e);
      notifyListeners();
      return false;
    }
  }

  // Google Sign In
  Future<bool> signInWithGoogle() async {
    try {
      _isGoogleLoading(true);
      _error = null;

      final UserCredential? credential = await _authService.signInWithGoogle();

      if (credential?.user != null) {
        final String fcmToken = await _getFcmToken();
        final existingUser =
            await _authService.getUserData(credential!.user!.uid);

        if (existingUser == null) {
          // New user - create account
          await _authService.createOrUpdateUser(
            uid: credential.user!.uid,
            name: credential.user!.displayName ?? 'User',
            email: credential.user!.email ?? '',
            phone: credential.user!.phoneNumber ?? '',
            fcmToken: fcmToken,
          );
        } else {
          // Existing user - update FCM token if needed
          if (existingUser.fcmToken != fcmToken) {
            await _authService.createOrUpdateUser(
              uid: existingUser.id,
              name: existingUser.name,
              phone: existingUser.phone,
              email: existingUser.email,
              address: existingUser.address,
              fcmToken: fcmToken,
            );
          }
        }

        _authService.saveUserDataToLocal(existingUser ??
            UserModel(
              id: credential.user!.uid,
              name: credential.user!.displayName ?? 'User',
              phone: credential.user!.phoneNumber ?? '',
              email: credential.user!.email ?? '',
              fcmToken: fcmToken,
            ));
      }

      _isGoogleLoading(false);
      return credential != null;
    } catch (e) {
      _isGoogleLoading(false);
      _error = ErrorFormatter.formatAuthError(e);
      notifyListeners();
      return false;
    }
  }

  // Send Password Reset Email
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      _setLoading(true);
      _error = null;

      await _authService.sendPasswordResetEmail(email);

      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _error = ErrorFormatter.formatAuthError(e);
      notifyListeners();
      return false;
    }
  }

  // Update user details
  Future<bool> updateUserDetails(
      {String? name, String? address, String? phone}) async {
    if (_currentUser == null) return false;

    try {
      _setLoading(true);
      _error = null;

      await _authService.createOrUpdateUser(
        uid: _currentUser!.id,
        name: name ?? _currentUser!.name,
        phone: phone ?? _currentUser!.phone,
        email: _currentUser!.email,
        address: address ?? _currentUser!.address,
        fcmToken: _currentUser!.fcmToken,
      );
      _authService.saveUserDataToLocal(
        _currentUser!.copyWith(
          name: name ?? _currentUser!.name,
          phone: phone ?? _currentUser!.phone,
          address: address ?? _currentUser!.address,
        ),
      );
      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _error = ErrorFormatter.formatAuthError(e);
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
      print('Error getting FCM token: ${ErrorFormatter.formatAuthError(e)}');
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
          email: _currentUser!.email,
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

  void _isGoogleLoading(bool value) {
    _isGLoading = value;
    notifyListeners();
  }

  void setErrorMessage(String? message) {
    _error = message;
    notifyListeners();
  }
}
