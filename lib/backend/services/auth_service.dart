// lib/services/firebase_auth_service.dart
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/user_model.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<UserModel?> get currentUser =>
      _auth.authStateChanges().asyncMap((User? user) async {
        if (user != null) {
          return await getUserData(user.uid);
        }
        return null;
      });

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
      print('Error checking phone number: ${e.toString()}');
      return false;
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
          throw e;
        },
        codeSent: (String verificationId, int? resendToken) {
          verificationIdCompleter.complete(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );

      return await verificationIdCompleter.future;
    } catch (e) {
      throw Exception('Failed to send OTP: ${e.toString()}');
    }
  }

  // Verify OTP and sign in
  Future<UserCredential> verifyOTP(String verificationId, String otp) async {
    try {
      print('Starting OTP verification with ID: $verificationId, OTP: $otp');
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );
      print('Credential created: ${credential.toString()}');
      final result = await _auth.signInWithCredential(credential);
      print('Sign-in result: $result');
      print('User: ${result.user}');
      return result;
    } catch (e) {
      print('Error during OTP verification: $e');
      throw Exception('Failed to verify OTP: ${e.toString()}');
    }
  }

  // Create or update user in Firestore
  Future<UserModel> createOrUpdateUser({
    required String uid,
    required String name,
    required String phone,
    String? address,
    String? fcmToken,
  }) async {
    final UserModel user = UserModel(
      id: uid,
      name: name,
      phone: phone,
      address: address ?? '',
      fcmToken: fcmToken ?? '',
    );
    await _firestore.collection('users').doc(uid).set(user.toMap());
    return user;
  }

  // Get user data from Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error getting user data: ${e.toString()}');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
