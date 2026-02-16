import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginController {
  final nationalIdCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  bool submitted = false;
  bool isLoading = false;

  bool obscurePassword = true; // ✅ جديد
  String? serverError;

  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
  }

  bool get isNationalIdValid {
    final v = nationalIdCtrl.text.trim();
    if (v.length != 10) return false;
    return v.startsWith('1') || v.startsWith('2');
  }

  bool get hasMinLength => passwordCtrl.text.length >= 8;
  bool get hasLetter => RegExp(r'[A-Za-z]').hasMatch(passwordCtrl.text);
  bool get hasNumber => RegExp(r'\d').hasMatch(passwordCtrl.text);
  bool get hasSpecialChar => RegExp(r'[^A-Za-z0-9]').hasMatch(passwordCtrl.text);

  bool get isPasswordValid => hasMinLength && hasLetter && hasNumber && hasSpecialChar;
  bool get allRequiredValid => isNationalIdValid && isPasswordValid;

  void submit() => submitted = true;

  void dispose() {
    nationalIdCtrl.dispose();
    passwordCtrl.dispose();
  }

  Future<String?> _emailByNationalId(String nid) async {
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .where('nationalId', isEqualTo: nid)
        .limit(1)
        .get();

    if (snap.docs.isEmpty) return null;
    final data = snap.docs.first.data();
    final email = (data['email'] ?? '').toString().trim();
    return email.isEmpty ? null : email;
  }

  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-credential':
      case 'wrong-password':
        return 'National ID / Password is incorrect.';
      case 'user-not-found':
        return 'No user found for this account.';
     /* case 'too-many-requests':
        return 'Too many attempts. Try again later.';*/
      case 'network-request-failed':
        return 'Check your internet connection.';
      case 'operation-not-allowed':
        return 'Email/Password sign-in is not enabled.';
      default:
        return e.message ?? 'Login failed. (${e.code})';
    }
  }

  Future<bool> login() async {
    serverError = null;
    submitted = true;

    if (!allRequiredValid) {
      serverError = 'Please fix the highlighted fields.';
      return false;
    }

    final nid = nationalIdCtrl.text.trim();
    final pass = passwordCtrl.text;

    isLoading = true;

    try {
      final email = await _emailByNationalId(nid);
      if (email == null) {
        serverError = 'No account found for this National ID / Iqama.';
        return false;
      }

 

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: pass,
      );

     /* await Future.delayed(Duration(seconds: 1));
  return true;*/ //كنت اتأكد من انها قاعدة تنتقل من صفحة اللوق ان 

      return true;
    } on FirebaseAuthException catch (e) {
      serverError = _mapAuthError(e);
      return false;
    } catch (_) {
      serverError = 'Something went wrong. Try again.';
      return false;
    } finally {
      isLoading = false;
    }
  }

  Future<bool> forgotPassword() async {
    serverError = null;

    final nid = nationalIdCtrl.text.trim();
    if (!isNationalIdValid) {
      serverError = 'Enter a valid National ID / Iqama first.';
      return false;
    }

    try {
      final email = await _emailByNationalId(nid);
      if (email == null) {
        serverError = 'No account found for this National ID / Iqama.';
        return false;
      }

      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      return true;
    } on FirebaseAuthException catch (e) {
      serverError = e.message ?? 'Could not send reset email.';
      return false;
    } catch (_) {
      serverError = 'Something went wrong. Try again.';
      return false;
    }
  }
}
