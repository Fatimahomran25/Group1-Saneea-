import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../models/admin_model.dart';
import '../models/admin_home_item_model.dart';

class AdminController {
  // ✅ Home list (Dummy حالياً)
  final List<AdminHomeItemModel> items = const [
    AdminHomeItemModel(number: 1, name: "Lana Alyousef"),
    AdminHomeItemModel(number: 2, name: "Nourah Almajed"),
    AdminHomeItemModel(number: 3, name: "Bader Alotaiby"),
    AdminHomeItemModel(number: 1, name: "Maha Abohaimed"),
    AdminHomeItemModel(number: 5, name: "Meshal Alharby"),
    AdminHomeItemModel(number: 7, name: "Abdullah Abdulrahman"),
    AdminHomeItemModel(number: 10, name: "Mohammad Waleed"),
    AdminHomeItemModel(number: 1, name: "Lamya Alsayari"),
  ];

  // ✅ Fallback (لو ما رجع شيء من Firebase)
  AdminModel getAdmin() {
    return const AdminModel(
      name: "Admin",
      role: "Admin",
      nationalId: "----------",
      email: "----------",
      photoAssetPath: "assets/admin.png",
      photoUrl: null, // ✅ جديد
    );
  }

  // ==========================
  // Firebase: Get Admin Data
  // ==========================
  Future<AdminModel> getAdminFromFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return getAdmin();

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final data = doc.data();
    if (data == null) return getAdmin();

    final first = (data['firstName'] ?? '').toString().trim();
    final last = (data['lastName'] ?? '').toString().trim();
    final email = (data['email'] ?? '').toString().trim();
    final nationalId = (data['nationalId'] ?? '').toString().trim();
    final role = (data['accountType'] ?? 'Admin').toString().trim();

    // ✅ هذا هو رابط الصورة من Firestore
    final photoUrl = (data['photoUrl'] ?? '').toString().trim();

    final fullName =
        ([first, last]..removeWhere((e) => e.isEmpty)).join(' ').trim();
    final safeName = fullName.isEmpty ? "Admin" : fullName;

    return AdminModel(
      name: safeName,
      role: role.isEmpty ? "Admin" : role,
      nationalId: nationalId.isEmpty ? getAdmin().nationalId : nationalId,
      email: email.isEmpty ? getAdmin().email : email,

      // ✅ إذا ما فيه رابط نخليها null ونستخدم asset في الواجهة
      photoUrl: photoUrl.isEmpty ? null : photoUrl,

      // ✅ احتياطي: إذا ما فيه photoUrl نعرض asset
      photoAssetPath: getAdmin().photoAssetPath,
    );
  }

  Future<String> getAdminFullName() async {
    final admin = await getAdminFromFirebase();
    return admin.name.isEmpty ? "Admin" : admin.name;
  }

  // ==========================
  // Upload Profile Photo
  // ==========================
  Future<void> pickAndUploadAdminPhoto(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final picker = ImagePicker();
      final XFile? picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (picked == null) return;

      final file = File(picked.path);

      // Storage path: profile_photos/{uid}.jpg
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_photos')
          .child('${user.uid}.jpg');

      await ref.putFile(file);

      final url = await ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'photoUrl': url});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile photo updated ✅")),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update photo ❌")),
      );
    }
  }

  // ==========================
  // Navigation
  // ==========================
  void openProfile(BuildContext context) {
    Navigator.pushNamed(context, '/adminProfile');
  }

  void back(BuildContext context) {
    Navigator.pop(context);
  }

  // ==========================
  // Actions
  // ==========================
  void deleteItem(BuildContext context, AdminHomeItemModel item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Delete: ${item.name} (${item.number})")),
    );
  }

  Future<void> resetPassword(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final email = user?.email;

      if (email == null || email.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No email found for this account.")),
        );
        return;
      }

      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password reset email sent.")),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to send reset email.")),
      );
    }
  }

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }
}