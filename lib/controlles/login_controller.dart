import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginController {
  
  final nationalIdCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  bool submitted = false;
  bool isLoading = false;

  bool obscurePassword = true; 
  String? serverError;
  bool isAdminMode = false;

  void setAdminMode(bool v) {
  isAdminMode = v;
  serverError = null;
  submitted = false;
}

  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
  }

  bool get isNationalIdValid {
    final v = nationalIdCtrl.text.trim();
    //if (v.length != 10) return false;
    //return v.startsWith('1') || v.startsWith('2');
      return v.length == 10;
  }

  bool get hasMinLength => passwordCtrl.text.length >= 8;
  bool get hasLetter => RegExp(r'[A-Za-z]').hasMatch(passwordCtrl.text);
  bool get hasNumber => RegExp(r'\d').hasMatch(passwordCtrl.text);
  bool get hasSpecialChar => RegExp(r'[^A-Za-z0-9]').hasMatch(passwordCtrl.text);

  bool get isPasswordValid => hasMinLength && hasLetter && hasNumber && hasSpecialChar;
  bool get allRequiredValid => isNationalIdValid && isPasswordValid;


bool get isEmailValid {
  final v = nationalIdCtrl.text.trim();
  return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v);
}

  void submit() => submitted = true;

  void dispose() {
    nationalIdCtrl.dispose();
    passwordCtrl.dispose();
  }
Future<String?> loginRole() async {
  serverError = null;
  submitted = true;
String? nationalIdError;
String? passwordError;

void clearErrors() {
  nationalIdError = null;
  passwordError = null;
}

  if (!allRequiredValid) {
    serverError = 'Please fix the highlighted fields.';
    return null;
  }

  final idOrEmail = nationalIdCtrl.text.trim();
  final pass = passwordCtrl.text;

  isLoading = true;
  try {
    String emailToUse;

    if (isAdminMode) {
      // ✅ Admin يدخل مباشرة بإيميل
      emailToUse = idOrEmail;
    } else {
      // ✅ User يدخل بـ National ID -> نطلع الإيميل من Firestore
      final email = await _emailByNationalId(idOrEmail);
      if (email == null) {
        serverError = 'No account found for this National ID / Iqama.';
        return null;
      }
      emailToUse = email;
    }

    final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: emailToUse.trim(),
      password: pass,
    );

    final uid = cred.user?.uid;
    if (uid == null) return 'user';

    final adminDoc = await FirebaseFirestore.instance
        .collection('admins')
        .doc(uid)
        .get();

    return adminDoc.exists ? 'admin' : 'user';
  } on FirebaseAuthException catch (e) {
    serverError = _mapAuthError(e);
    return null;
  } catch (_) {
    serverError = 'Something went wrong. Try again.';
    return null;
  } finally {
    isLoading = false;
  }
}
Future<String?> _emailByAdminId(String adminId) async {
  final doc = await FirebaseFirestore.instance
      .collection('admins')
      .doc(adminId)
      .get();

  if (!doc.exists) return null;

  final data = doc.data();
  final email = (data?['email'] ?? '').toString().trim();
  return email.isEmpty ? null : email;
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
  Future<String?> getAccountTypeForCurrentUser() async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return null;

  final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
  return (doc.data()?['accountType'] ?? '').toString().toLowerCase().trim();
}

  
String? nationalIdError;
String? passwordError;

  String _mapAuthError(FirebaseAuthException e) {//هذه الدالة:
//تشتغل فقط إذا Firebase فشل
//تحول error codes إلى رسائل بشرية
//تحفظ الرسالة في serverError
//وتطلع في الشاشة
    switch (e.code) {
      case 'invalid-credential':
      case 'wrong-password':
        return 'National ID / Password is incorrect.';
      case 'user-not-found':
        return 'No user found for this account.';
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
  if (!isNationalIdValid) {
    serverError = 'Enter a valid National ID / Iqama.';
  } else if (!isPasswordValid) {
    serverError = 'Password format is incorrect.';
  } else {
    serverError = 'Please check your input.';
  }
  return false;
}


    final nid = nationalIdCtrl.text.trim();
    final pass = passwordCtrl.text;

    isLoading = true;

    try {
     
      String? email_admin = await _emailByAdminId(nid);
      email_admin ??= await _emailByNationalId(nid);
if (email_admin == null) {
    serverError = 'No account found for this ID.';
    return false;
  }
      //final email = await _emailByNationalId(nid);
      /*if (email == null) {
        
        serverError = 'No account found for this National ID / Iqama.';
        return false;
      }*/

 

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email_admin.trim(),
        password: pass,
      );


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
