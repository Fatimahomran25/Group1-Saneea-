import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginController {
  // ===== Controllers =====
  final nationalIdCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  // ===== UI/STATE =====
  bool submitted = false;
  String? serverError;

  // ===== VALIDATION =====

  // (نخليه متوافق مع Signup: 10 أرقام + يبدأ بـ 1 أو 2)
  bool get isNationalIdValid {
    final v = nationalIdCtrl.text.trim();
    if (v.length != 10) return false;
    if (!RegExp(r'^\d{10}$').hasMatch(v)) return false;
    return v.startsWith('1') || v.startsWith('2');
  }

  // Password rules (حسب طلبك: طول 13 + حرف + رقم + special)
  bool get passHasLen13 => passwordCtrl.text.length == 13;
  bool get passHasLetter => RegExp(r'[A-Za-z]').hasMatch(passwordCtrl.text);
  bool get passHasNumber => RegExp(r'\d').hasMatch(passwordCtrl.text);
  bool get passHasSpecial => RegExp(r'[^A-Za-z0-9]').hasMatch(passwordCtrl.text);

  bool get isPasswordValid => passHasLen13 && passHasLetter && passHasNumber && passHasSpecial;

  bool get allRequiredValid => isNationalIdValid && isPasswordValid;

  // ===== ACTIONS =====
  void submit() {
    submitted = true;
  }

  void dispose() {
    nationalIdCtrl.dispose();
    passwordCtrl.dispose();
  }

  Future<void> login(BuildContext context) async {
    serverError = null;

    // 0) تحقق محلي
    if (!allRequiredValid) return;

    final nationalId = nationalIdCtrl.text.trim();
    final password = passwordCtrl.text;

    try {
      // 1) نجيب الايميل من Firestore عن طريق nationalId
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .where('nationalId', isEqualTo: nationalId)
          .limit(1)
          .get();

      if (snap.docs.isEmpty) {
        serverError = "National ID / Iqama not found.";
        return;
      }

      final data = snap.docs.first.data();
      final email = (data['email'] ?? '').toString().trim();

      if (email.isEmpty) {
        serverError = "No email linked to this National ID.";
        return;
      }

      // 2) نسوي sign in بالايميل + الباسورد
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // ✅ نجاح — TODO: هنا Navigate للصفحة المناسبة
      // Navigator.pushReplacementNamed(context, '/home');

    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        serverError = "Incorrect password.";
      } else if (e.code == 'user-not-found') {
        serverError = "Account not found.";
      } else {
        serverError = e.message ?? "Login error.";
      }
    } catch (e) {
      serverError = "Something went wrong. Try again.";
    }
  }

  void signupTap(BuildContext context) {
    Navigator.pushNamed(context, '/signup');
  }
}
