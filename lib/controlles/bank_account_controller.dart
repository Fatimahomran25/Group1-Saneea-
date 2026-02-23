import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/bank_account_model.dart';

class BankAccountController extends ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  bool isLoading = true;
  bool isSaving = false;
  String? error;

  List<BankAccountModel> accounts = [];

  // form
  final ibanCtrl = TextEditingController();

  // IBAN validation (SA + 24 chars total عادةً، نخليها مرنة شوي)
  String? validateIban(String? v) {
    final s = (v ?? '').trim().replaceAll(' ', '');
    if (s.isEmpty) return 'IBAN is required';
    if (!s.toUpperCase().startsWith('SA')) return 'IBAN must start with SA';
    if (s.length < 15) return 'IBAN is too short';
    return null;
  }

  CollectionReference<Map<String, dynamic>> _col(String uid) {
    return _db.collection('users').doc(uid).collection('bank_accounts');
  }

  Future<void> init() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final user = _auth.currentUser;
      if (user == null) {
        error = 'Not logged in';
        isLoading = false;
        notifyListeners();
        return;
      }

      final snap = await _col(user.uid).orderBy('createdAt', descending: true).get();

      accounts = snap.docs
          .map((d) => BankAccountModel.fromFirestore(id: d.id, data: d.data()))
          .toList();

      // تأكد: لو ما فيه default وخانة موجودة، خله أول واحد default
      if (accounts.isNotEmpty && !accounts.any((e) => e.isDefault)) {
        await setDefault(accounts.first.id, silent: true);
      }

      isLoading = false;
      notifyListeners();
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addIban() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final iban = ibanCtrl.text.trim().replaceAll(' ', '');
    if (iban.isEmpty) return;

    isSaving = true;
    notifyListeners();

    try {
      final now = DateTime.now();
      final docRef = await _col(user.uid).add({
        'iban': iban,
        'isDefault': accounts.isEmpty, // أول واحد يصير default
        'createdAt': Timestamp.fromDate(now),
      });

      final newItem = BankAccountModel(
        id: docRef.id,
        iban: iban,
        isDefault: accounts.isEmpty,
        createdAt: now,
      );

      accounts = [newItem, ...accounts];
      ibanCtrl.clear();

      isSaving = false;
      notifyListeners();
    } catch (e) {
      error = e.toString();
      isSaving = false;
      notifyListeners();
    }
  }

  Future<void> updateIban({
    required String id,
    required String newIban,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final iban = newIban.trim().replaceAll(' ', '');
    if (iban.isEmpty) return;

    isSaving = true;
    notifyListeners();

    try {
      await _col(user.uid).doc(id).update({'iban': iban});

      accounts = accounts.map((a) {
        if (a.id != id) return a;
        return a.copyWith(iban: iban);
      }).toList();

      isSaving = false;
      notifyListeners();
    } catch (e) {
      error = e.toString();
      isSaving = false;
      notifyListeners();
    }
  }

  Future<void> deleteIban(String id) async {
    final user = _auth.currentUser;
    if (user == null) return;

    isSaving = true;
    notifyListeners();

    try {
      final wasDefault = accounts.firstWhere((a) => a.id == id).isDefault;

      await _col(user.uid).doc(id).delete();
      accounts = accounts.where((a) => a.id != id).toList();

      // لو حذفنا default: خلي أول واحد default
      if (wasDefault && accounts.isNotEmpty) {
        await setDefault(accounts.first.id, silent: true);
      }

      isSaving = false;
      notifyListeners();
    } catch (e) {
      error = e.toString();
      isSaving = false;
      notifyListeners();
    }
  }

  Future<void> setDefault(String id, {bool silent = false}) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // اجعل الكل false ثم واحد true (batch)
      final batch = _db.batch();

      for (final a in accounts) {
        final ref = _col(user.uid).doc(a.id);
        batch.update(ref, {'isDefault': a.id == id});
      }

      await batch.commit();

      accounts = accounts.map((a) => a.copyWith(isDefault: a.id == id)).toList();

      if (!silent) notifyListeners();
    } catch (e) {
      error = e.toString();
      if (!silent) notifyListeners();
    }
  }

  @override
  void dispose() {
    ibanCtrl.dispose();
    super.dispose();
  }
}