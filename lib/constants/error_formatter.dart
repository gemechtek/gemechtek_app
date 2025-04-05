// lib/utils/error_formatter.dart
import 'package:firebase_auth/firebase_auth.dart';

class ErrorFormatter {
  // Format Firebase authentication errors into user-friendly messages
  static String formatAuthError(dynamic error) {
    if (error is FirebaseAuthException) {
      return _formatFirebaseAuthError(error);
    } else if (error is Exception) {
      // If it's a custom exception from our code
      final message = error.toString();
      if (message.contains('Exception: ')) {
        return message.replaceAll('Exception: ', '');
      }
      return 'An error occurred. Please try again.';
    } else {
      return 'Unknown error occurred. Please try again.';
    }
  }

  // Format Firebase Auth specific errors
  static String _formatFirebaseAuthError(FirebaseAuthException error) {
    switch (error.code) {
      // Phone verification errors
      case 'invalid-phone-number':
        return 'The phone number provided is invalid. Please enter a valid phone number.';
      case 'quota-exceeded':
        return 'SMS quota has been exceeded. Please try again later.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'operation-not-allowed':
        return 'Phone authentication is not enabled. Please contact support.';
      case 'session-expired':
        return 'The verification code has expired. Please request a new code.';
      case 'invalid-verification-code':
        return 'The verification code you entered is invalid. Please check and try again.';
      case 'invalid-verification-id':
        return 'The verification session has expired. Please restart the verification.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'provider-already-linked':
        return 'This phone number is already linked to an account.';
      case 'credential-already-in-use':
        return 'This phone number is already in use by another account.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with the same phone number but different sign-in credentials.';
      default:
        return error.message ??
            'An authentication error occurred. Please try again.';
    }
  }

  // Format Firestore errors
  static String formatFirestoreError(dynamic error) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return 'You do not have permission to perform this action.';
        case 'unavailable':
          return 'The service is currently unavailable. Please check your connection and try again.';
        case 'not-found':
          return 'The requested information could not be found.';
        case 'already-exists':
          return 'This information already exists in our records.';
        default:
          return error.message ??
              'A database error occurred. Please try again.';
      }
    }
    return 'An error occurred while accessing the database. Please try again.';
  }
}
