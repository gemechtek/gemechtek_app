import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../model/user_model.dart';

import '../../constants/error_formatter.dart';
import 'local_pref.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocalPreferenceService _localPrefs = LocalPreferenceService();

  Stream<UserModel?> get currentUser =>
      _auth.authStateChanges().asyncMap((User? user) async {
        if (user != null) {
          final userData = await getUserData(user.uid);
          if (userData != null) {
            // Update local storage whenever Firebase auth state changes
            await _localPrefs.saveUserData(userData);
            return userData;
          }
        } else {
          // Clear local storage when user signs out from Firebase
          await _localPrefs.clearUserData();
        }
        return null;
      });

  // Check if user is already authenticated from local storage
  Future<UserModel?> getCurrentUserFromLocal() async {
    final isLoggedIn = await _localPrefs.isLoggedIn();
    if (isLoggedIn) {
      return await _localPrefs.getUserData();
    }
    return null;
  }

  // Check if phone number exists in Firestore
  Future<bool> doesPhoneNumberExist(String phoneNumber) async {
    try {
      final QuerySnapshot result = await _firestore
          .collection('users')
          .where('phone', isEqualTo: phoneNumber)
          .limit(1)
          .get();
      return result.docs.isNotEmpty;
    } catch (e) {
      throw Exception(ErrorFormatter.formatFirestoreError(e));
    }
  }

  // Send OTP to phone number (only if phone exists during login)
  Future<String> sendOTP(String phoneNumber, {required bool isLogin}) async {
    try {
      final phoneExists = await doesPhoneNumberExist(phoneNumber);

      if (isLogin && !phoneExists) {
        throw Exception('No account found with this phone number.');
      } else if (!isLogin && phoneExists) {
        throw Exception('An account already exists with this phone number.');
      }

      final verificationIdCompleter = Completer<String>();

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          verificationIdCompleter
              .completeError(ErrorFormatter.formatAuthError(e));
        },
        codeSent: (String verificationId, int? resendToken) {
          verificationIdCompleter.complete(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );

      return await verificationIdCompleter.future;
    } catch (e) {
      throw Exception(ErrorFormatter.formatAuthError(e));
    }
  }

  // Verify OTP and sign in
  Future<UserCredential> verifyOTP(String verificationId, String otp) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );
      final result = await _auth.signInWithCredential(credential);
      return result;
    } catch (e) {
      throw Exception(ErrorFormatter.formatAuthError(e));
    }
  }

  // Create or update user in Firestore and local storage
  Future<UserModel> createOrUpdateUser({
    required String uid,
    required String name,
    required String phone,
    String? address,
    String? fcmToken,
  }) async {
    try {
      final UserModel user = UserModel(
        id: uid,
        name: name,
        phone: phone,
        address: address ?? '',
        fcmToken: fcmToken ?? '',
      );

      // Update Firestore
      await _firestore.collection('users').doc(uid).set(user.toMap());

      // Update local storage
      await _localPrefs.saveUserData(user);

      return user;
    } catch (e) {
      throw Exception(ErrorFormatter.formatFirestoreError(e));
    }
  }

  // Get user data from Firestore and update local storage
  Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();

      if (doc.exists) {
        final userData = UserModel.fromMap(doc.data() as Map<String, dynamic>);

        // Update local storage with latest data from Firestore
        await _localPrefs.saveUserData(userData);

        return userData;
      }
      return null;
    } catch (e) {
      throw Exception(ErrorFormatter.formatFirestoreError(e));
    }
  }

  // Sign out from Firebase and clear local storage
  Future<void> signOut() async {
    try {
      // Clear local storage first
      await _localPrefs.clearUserData();

      // Then sign out from Firebase
      await _auth.signOut();
    } catch (e) {
      throw Exception(ErrorFormatter.formatAuthError(e));
    }
  }
}
