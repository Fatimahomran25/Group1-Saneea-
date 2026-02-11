import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/signup_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignupController {
  final SignupModel model = SignupModel();

  final nationalIdCtrl = TextEditingController();
  final firstNameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();

  // ===== UI/STATE =====
  bool submitted = false;
  String? serverError;

  // ===== HELPERS =====
  bool _isOnlyLetters(String v) => RegExp(r'^[a-zA-Z]+$').hasMatch(v);

  // ===== VALIDATION =====
  bool get isAccountTypeSelected => model.accountType != null;

  bool get isNationalIdValid {
    final v = nationalIdCtrl.text.trim();
    if (v.length != 10) return false;
    return v.startsWith('1') || v.startsWith('2');
  }

  bool get isFirstNameValid {
    final v = firstNameCtrl.text.trim();
    if (v.isEmpty) return false;
    if (v.length > 15) return false;
    return _isOnlyLetters(v);
  }

  bool get isLastNameValid {
    final v = lastNameCtrl.text.trim();
    if (v.isEmpty) return false;
    if (v.length > 15) return false;
    return _isOnlyLetters(v);
  }

  bool get isEmailValid {
    final v = emailCtrl.text.trim();
    if (v.isEmpty) return false;
    final gmailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$');
    return gmailRegex.hasMatch(v);
  }

  // Password rules (10 + number + special)
  bool get hasMinLength => passwordCtrl.text.length >= 10;
  bool get hasNumber => RegExp(r'\d').hasMatch(passwordCtrl.text);
  
  bool get isPasswordValid => hasMinLength && hasNumber && hasSpecialChar;
  bool get isPasswordStrong =>
    hasMinLength && hasNumber && hasSpecialChar;

bool get hasSpecialChar =>
    RegExp(r'[!@#$%^&*(),.?":{}|<>_\-]')
        .hasMatch(passwordCtrl.text);

  bool get isConfirmPasswordValid =>
      confirmPasswordCtrl.text.isNotEmpty &&
      confirmPasswordCtrl.text == passwordCtrl.text;

  bool get allRequiredValid =>
      isAccountTypeSelected &&
      isNationalIdValid &&
      isFirstNameValid &&
      isLastNameValid &&
      isEmailValid &&
      isPasswordValid &&
      isConfirmPasswordValid;

  // ===== ACTIONS =====
  void setAccountType(AccountType type) {
    model.accountType = type;
  }

  void submit() {
    submitted = true;
  }

  void dispose() {
    nationalIdCtrl.dispose();
    firstNameCtrl.dispose();
    lastNameCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    confirmPasswordCtrl.dispose();
  }

  Future<AccountType?> createAccount() async {
  serverError = null;
  if (!allRequiredValid) return null;

  final nationalId = nationalIdCtrl.text.trim();
  final firstName  = firstNameCtrl.text.trim();
  final lastName   = lastNameCtrl.text.trim();
  final email      = emailCtrl.text.trim();
  final password   = passwordCtrl.text;
  final accountType = model.accountType!;

  try {
    final existing = await FirebaseFirestore.instance
        .collection('users')
        .where('nationalId', isEqualTo: nationalId)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      serverError = "National ID / Iqama already exists.";
      return null;
    }

    final credential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);

    final uid = credential.user!.uid;

    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'accountType': accountType.name,
      'nationalId': nationalId,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return accountType; // ✅ هذا الجديد
  } on FirebaseAuthException catch (e) {
    serverError = e.code == 'email-already-in-use'
        ? "Email already exists. Try a different email."
        : (e.message ?? "Auth error.");
    return null;
  } catch (_) {
    serverError = "Something went wrong. Try again.";
    return null;
  }
   on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        serverError = "Email already exists. Try a different email.";
      } else {
        serverError = e.message ?? "Auth error.";
      }
    } catch (_) {
      serverError = "Something went wrong. Try again.";
    }
  }

  void loginTap(BuildContext context) {
    Navigator.pushNamed(context, '/login');
  }
}



      // TODO: هنا سوي navigation حسب accountType
      // if (accountType == AccountType.freelancer) ...
      // else ...

    
