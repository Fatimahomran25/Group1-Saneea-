import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/freelancer_profile_model.dart';

class FreelancerProfileController extends ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;
 final _storage = FirebaseStorage.instance;
  bool isLoading = true;
  bool isSaving = false;
  bool isEditing = false;

  String? error;

  FreelancerProfileModel? profile;

  // text controllers
  final nameCtrl = TextEditingController();
  final titleCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final bioCtrl = TextEditingController();

  // ✅ IBAN
  final ibanCtrl = TextEditingController();

  // picked image (local only for now)
  File? pickedImageFile;

  // portfolio local only (إذا عندك بالفيـو)
  final List<File> pickedPortfolioFiles = [];

  static const int bioMax = 150;

  // ✅ gmail فقط
  final RegExp gmailReg = RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$');

  // options
  static const List<String> serviceTypeOptions = [
    "one-time",
    "part-time",
    "full-time",
  ];

  static const List<String> workingModeOptions = [
    "in person",
    "remote",
    "hybrid",
  ];

  int get bioLen => bioCtrl.text.length;

  Future<void> init() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final user = _auth.currentUser;
      if (user == null) {
        error = "Not logged in";
        isLoading = false;
        notifyListeners();
        return;
      }

      final doc = await _db.collection('users').doc(user.uid).get();
      final data = doc.data();

      if (data == null) {
        error = "User data not found";
        isLoading = false;
        notifyListeners();
        return;
      }

      // ✅ rating والreviews مو شغالين بهالفيز
      profile = FreelancerProfileModel.fromFirestore(
        uid: user.uid,
        data: data,
        rating: 0.0,
      );

      nameCtrl.text = profile!.name;
      titleCtrl.text = profile!.title;
      emailCtrl.text = profile!.email;
      bioCtrl.text = profile!.bio;
      ibanCtrl.text = profile!.iban ?? "";

      bioCtrl.removeListener(_bioListener);
      bioCtrl.addListener(_bioListener);

      isLoading = false;
      notifyListeners();
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  void _bioListener() => notifyListeners();

  // ===== edit flow =====
  void startEdit() {
    if (profile == null) return;
    isEditing = true;
    notifyListeners();
  }

  void cancelEdit() {
    if (profile == null) return;

    isEditing = false;
    pickedImageFile = null;
    pickedPortfolioFiles.clear();

    nameCtrl.text = profile!.name;
    titleCtrl.text = profile!.title;
    emailCtrl.text = profile!.email;
    bioCtrl.text = profile!.bio;
    ibanCtrl.text = profile!.iban ?? "";

    notifyListeners();
  }

  // ===== validators =====
  String? validateName(String? v) {
    final value = (v ?? '').trim();
    if (value.isEmpty) return "Name is required";
    if (value.length < 2) return "Name is too short";
    return null;
  }

  String? validateTitle(String? v) {
  final value = (v ?? '').trim();

  if (value.isEmpty) {
    return "Job title is required";
  }

  if (value.length < 2) {
    return "Job title is too short";
  }

  return null;
}

  String? validateBio(String? v) {
    final value = (v ?? '');
    if (value.length > bioMax) return "Bio must be $bioMax characters or less";
    return null;
  }

  String? validateGmail(String? v) {
    final value = (v ?? '').trim();
    if (value.isEmpty) return "Email is required";
    if (!gmailReg.hasMatch(value)) return "Enter a valid email (name@gmail.com)";
    return null;
  }

  // ✅ IBAN (خفيف، فقط صيغة عامة + يبدأ بـ SA)
  String? validateIban(String? v) {
    if (!isEditing) return null;
    final s = (v ?? '').trim().replaceAll(' ', '');
    if (s.isEmpty) return null; // خليناه اختياري
    if (!s.toUpperCase().startsWith('SA')) return "IBAN must start with SA";
    if (s.length < 15) return "IBAN is too short";
    return null;
  }

  // ===== image/portfolio (local only) =====
  void setPickedImage(File file) {
    if (!isEditing) return;
    pickedImageFile = file;
    notifyListeners();
  }

  void addPortfolioFiles(List<File> files) {
    if (!isEditing) return;
    pickedPortfolioFiles.addAll(files);
    notifyListeners();
  }

  void removePortfolioAt(int i) {
    if (!isEditing) return;
    if (i < 0 || i >= pickedPortfolioFiles.length) return;
    pickedPortfolioFiles.removeAt(i);
    notifyListeners();
  }

  // ===== update option fields =====
  void setServiceType(String v) {
    if (!isEditing || profile == null) return;
    profile = profile!.copyWith(serviceType: v);
    notifyListeners();
  }

  void setWorkingMode(String v) {
    if (!isEditing || profile == null) return;
    profile = profile!.copyWith(workingMode: v);
    notifyListeners();
  }

  void addExperience(ExperienceModel e) {
    if (!isEditing || profile == null) return;
    final list = [...profile!.experiences, e];
    profile = profile!.copyWith(experiences: list);
    notifyListeners();
  }

  void editExperience(int index, ExperienceModel e) {
    if (!isEditing || profile == null) return;
    final list = [...profile!.experiences];
    if (index < 0 || index >= list.length) return;
    list[index] = e;
    profile = profile!.copyWith(experiences: list);
    notifyListeners();
  }

  void deleteExperience(int index) {
    if (!isEditing || profile == null) return;
    final list = [...profile!.experiences];
    if (index < 0 || index >= list.length) return;
    list.removeAt(index);
    profile = profile!.copyWith(experiences: list);
    notifyListeners();
  }

  // ===== save =====
  Future<bool> save() async {
    if (profile == null) return false;

    isSaving = true;
    error = null;
    notifyListeners();

    try {
      final user = _auth.currentUser;
      if (user == null) throw "Not logged in";
      final uid = user.uid;
      String? photoUrl = profile!.photoUrl;

if (pickedImageFile != null) {
  final ref = _storage.ref().child('users/$uid/profile.jpg');

  await ref.putFile(pickedImageFile!);

  photoUrl = await ref.getDownloadURL();
}
      final newName = nameCtrl.text.trim();
      final parts = newName.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
      final firstName = parts.isNotEmpty ? parts.first : '';
      final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
      final newTitle = titleCtrl.text.trim();
      print('DEBUG: firstName=$firstName lastName=$lastName');
      if (newTitle.isEmpty) {
      error = 'Please enter your job title';
       notifyListeners();
       isSaving = false;
       return false;
       }
      final newEmail = emailCtrl.text.trim();

      final newBioRaw = bioCtrl.text;
      final safeBio =
          newBioRaw.length > bioMax ? newBioRaw.substring(0, bioMax) : newBioRaw;

      final newIban = ibanCtrl.text.trim().replaceAll(' ', '');
      // نخليه اختياري: لو فاضي نخزن null أو "" (أنا بخليه "")
      final ibanToSave = newIban.isEmpty ? "" : newIban;

      

       await  _db.collection('users').doc(user.uid).set({
      'name': newName,
      'firstName': firstName,      
      'lastName': lastName,
     'title': newTitle,
     'email': newEmail,
     'bio': safeBio,
    'serviceType': profile!.serviceType,
    'workingMode': profile!.workingMode,
    'experiences': profile!.experiences.map((e) => e.toMap()).toList(),
    'iban': ibanToSave,
  if (photoUrl != null) 'photoUrl': photoUrl,
}, SetOptions(merge: true));

      // تحديث Auth email (قد يتطلب إعادة تسجيل دخول)
      if (newEmail != user.email) {
        try {
          await user.updateEmail(newEmail);
        } catch (_) {}
      }

      profile = profile!.copyWith(
        name: newName,
        title: newTitle,
        email: newEmail,
        bio: safeBio,
        photoUrl: photoUrl,
        iban: ibanToSave.isEmpty ? null : ibanToSave,
      );

      isEditing = false;
      pickedImageFile = null;
      pickedPortfolioFiles.clear();

      isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      isSaving = false;
      notifyListeners();
      return false;
    }
  }

  // ===== actions =====
  Future<void> logout(BuildContext context) async {
    await _auth.signOut();
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
  }

  void goResetPassword(BuildContext context) {
    Navigator.pushNamed(context, '/forgotPassword');
  }

  Future<void> deleteAccount(BuildContext context) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _db.collection('users').doc(user.uid).delete();
      await user.delete();

      if (!context.mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/signup', (r) => false);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Delete failed: $e')),
      );
    }
  }

  @override
  void dispose() {
    bioCtrl.removeListener(_bioListener);

    nameCtrl.dispose();
    titleCtrl.dispose();
    emailCtrl.dispose();
    bioCtrl.dispose();
    ibanCtrl.dispose();

    super.dispose();
  }
}