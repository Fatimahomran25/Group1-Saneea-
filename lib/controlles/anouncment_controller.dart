import 'package:flutter/material.dart';
import '../models/anouncment_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AnnouncementController extends ChangeNotifier {
  AnnouncementModel _model = AnnouncementModel();

  final TextEditingController textController = TextEditingController();

  AnnouncementModel get model => _model;

  void onChanged(String value) {
    _model = _model.copyWith(query: value);
    notifyListeners();
  }

  Future<void> publish(BuildContext context) async {
    final message = textController.text.trim();

    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Write something before publishing')),
      );
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // 👇 نجيب بيانات اليوزر من users collection
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final firstName = userDoc.data()?['firstName'] ?? '';
      final lastName = userDoc.data()?['lastName'] ?? '';

      await FirebaseFirestore.instance.collection('announcements').add({
        'message': message,
        'createdAt': FieldValue.serverTimestamp(),
        'userId': user.uid,
        'userName': '$firstName $lastName', // 👈 اسم صاحب الإعلان
      });

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Publish failed: $e')));
    }
  }

  void cancel(BuildContext context) {
    Navigator.pop(context, false);
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }
}
