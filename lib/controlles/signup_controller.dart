import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/signup_model.dart';
import 'dart:async';

/// SignupController acts as the "Controller" for the SignupScreen:
/// - Holds TextEditingControllers for all input fields
/// - Provides validation getters used by the UI
/// - Stores lightweight UI state (submitted, serverError)
/// - Handles account creation using FirebaseAuth + Firestore
class SignupController {
  /// Data model that stores non-text state like the selected AccountType.
  final SignupModel model = SignupModel();

  /// Text controllers for reading and controlling the user's input in the UI.
  final nationalIdCtrl = TextEditingController();
  final firstNameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();

  // ===== UI/STATE =====

  /// Indicates whether the user attempted to submit the form.
  /// Used by the UI to show validation errors (red borders/messages).
  bool submitted = false;

  /// Holds server-side errors (Firebase/Auth/Firestore) to display in the UI.
  /// Example: email already exists, nationalId already exists, etc.
  String? serverError;
  bool isLoading = false;

  // ===== HELPERS =====

  /// Helper method used by name validation.
  /// Ensures the string contains letters only (A-Z / a-z).
  bool _isOnlyLetters(String v) => RegExp(r'^[a-zA-Z]+$').hasMatch(v);

  // ===== VALIDATION =====

  /// Checks whether the user selected an account type.
  /// The selection is stored in the model (not a text field).
  bool get isAccountTypeSelected => model.accountType != null;

  /// Validates Saudi National ID / Iqama based on:
  /// - Exactly 10 digits
  /// - Starts with 1 (National ID) or 2 (Iqama)
  bool get isNationalIdValid {
    final v = nationalIdCtrl.text.trim();
    if (v.length != 10) return false;
    return v.startsWith('1') || v.startsWith('2');
  }

  /// Validates first name:
  /// - Not empty
  /// - Max 15 characters
  /// - Letters only
  bool get isFirstNameValid {
    final v = firstNameCtrl.text.trim();
    if (v.isEmpty) return false;
    if (v.length > 15) return false;
    return _isOnlyLetters(v);
  }

  /// Validates last name:
  /// - Not empty
  /// - Max 15 characters
  /// - Letters only
  bool get isLastNameValid {
    final v = lastNameCtrl.text.trim();
    if (v.isEmpty) return false;
    if (v.length > 15) return false;
    return _isOnlyLetters(v);
  }

  /// Validates email format (restricted here to Gmail addresses only).
  /// This is UI/business requirement, not a Firebase requirement.
  bool get isEmailValid {
    final v = emailCtrl.text.trim();
    if (v.isEmpty) return false;
    final gmailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$');
    return gmailRegex.hasMatch(v);
  }

  /// Password rule #3: contains at least one special character.
  bool get hasSpecialChar =>
      RegExp(r'[!@#$%^&*(),.?":{}|<>_\-]').hasMatch(passwordCtrl.text);

  /// Password rule #2: contains at least one digit.
  bool get hasNumber => RegExp(r'\d').hasMatch(passwordCtrl.text);

  /// Password rule: contains at least one uppercase letter (A-Z).
  bool get hasUppercase => RegExp(r'[A-Z]').hasMatch(passwordCtrl.text);

  /// Password rule: contains at least one lowercase letter (a-z).
  bool get hasLowercase => RegExp(r'[a-z]').hasMatch(passwordCtrl.text);

  /// Password rule #0: contains at least 8 letters (A-Z / a-z).
  /// Password rule: at least 8 letters AND includes uppercase + lowercase.
  /// Password rule #0: contains at least 8 letters (A-Z / a-z).
  bool get hasAtLeast8Letters =>
      RegExp(r'[A-Za-z]').allMatches(passwordCtrl.text).length >= 8;

  /// Overall password validity (3 rules فقط)
  bool get isPasswordValid =>
      hasAtLeast8Letters && hasUppercase && hasLowercase;

  /// Same logic but named "Strong" for UI display purposes.
  bool get isPasswordStrong =>
      hasAtLeast8Letters && hasUppercase && hasLowercase;

  /// Confirm password must be non-empty and match the original password.
  bool get isConfirmPasswordValid =>
      confirmPasswordCtrl.text.isNotEmpty &&
      confirmPasswordCtrl.text == passwordCtrl.text;

  /// Aggregated validation used before attempting account creation.
  /// If false, UI should stop and show missing/invalid fields.
  bool get allRequiredValid =>
      isAccountTypeSelected &&
      isNationalIdValid &&
      isFirstNameValid &&
      isLastNameValid &&
      isEmailValid &&
      isPasswordValid &&
      isConfirmPasswordValid;

  // ===== ACTIONS =====

  /// Saves selected account type into the model.
  /// Called when user taps Freelancer/Client button.
  void setAccountType(AccountType type) {
    model.accountType = type;
  }

  /// Marks the form as submitted so UI can show validation feedback.
  void submit() {
    submitted = true;
  }

  /// Disposes all TextEditingControllers to prevent memory leaks.
  /// Called from the screen's dispose().
  void dispose() {
    nationalIdCtrl.dispose();
    firstNameCtrl.dispose();
    lastNameCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    confirmPasswordCtrl.dispose();
  }

  /// Creates a new user account:
  /// 1) Verifies allRequiredValid (client-side validation)
  /// 2) Checks if nationalId already exists in Firestore (business rule)
  /// 3) Creates FirebaseAuth user with email/password
  /// 4) Writes user profile data into Firestore using UID as document ID
  ///
  /// Returns:
  /// - AccountType on success (so the UI can navigate to the correct home page)
  /// - null on failure (and sets serverError for the UI)
  Future<AccountType?> createAccount() async {
    if (isLoading) return null;

    isLoading = true;
    serverError = null;

    try {
      if (!allRequiredValid) return null;

      final nationalId = nationalIdCtrl.text.trim();
      final firstName = firstNameCtrl.text.trim();
      final lastName = lastNameCtrl.text.trim();
      final email = emailCtrl.text.trim();
      final password = passwordCtrl.text;
      final accountType = model.accountType!;

      final existing = await FirebaseFirestore.instance
          .collection('users')
          .where('nationalId', isEqualTo: nationalId)
          .limit(1)
          .get()
          .timeout(const Duration(seconds: 8));

      if (existing.docs.isNotEmpty) {
        serverError = "National ID / Iqama already exists.";
        return null;
      }

      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password)
          .timeout(const Duration(seconds: 8));

      final uid = credential.user!.uid;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set({
            'accountType': accountType.name,
            'nationalId': nationalId,
            'firstName': firstName,
            'lastName': lastName,
            'email': email,
            'createdAt': FieldValue.serverTimestamp(),
          })
          .timeout(const Duration(seconds: 8));

      return accountType;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'network-request-failed') {
        serverError = "No internet connection.";
      } else if (e.code == 'email-already-in-use') {
        serverError = "Email already exists. Try a different email.";
      } else {
        serverError = e.message ?? "Auth error.";
      }
      return null;
    } on FirebaseException catch (e) {
      if (e.code == 'unavailable' || e.code == 'deadline-exceeded') {
        serverError = "No internet connection. Please try again.";
      } else {
        serverError = "Database error. Try again.";
      }
      return null;
    } on TimeoutException {
      serverError = "Connection timed out. Check your internet.";
      return null;
    } catch (_) {
      serverError = "Something went wrong. Try again.";
      return null;
    } finally {
      isLoading = false;
    }
  }

  /// Navigates to the login screen.
  /// Called when user clicks "Log in" link on the signup page.
  void loginTap(BuildContext context) {
    Navigator.pushNamed(context, '/login');
  }
}
