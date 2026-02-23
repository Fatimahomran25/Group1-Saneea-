import 'package:cloud_firestore/cloud_firestore.dart';

class BankAccountModel {
  final String id; // document id
  final String iban;
  final bool isDefault;
  final DateTime createdAt;

  const BankAccountModel({
    required this.id,
    required this.iban,
    required this.isDefault,
    required this.createdAt,
  });

  BankAccountModel copyWith({
    String? iban,
    bool? isDefault,
    DateTime? createdAt,
  }) {
    return BankAccountModel(
      id: id,
      iban: iban ?? this.iban,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'iban': iban,
      'isDefault': isDefault,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
  Map<String, dynamic> toMap() => toFirestore(); 
  static BankAccountModel fromFirestore({
    required String id,
    required Map<String, dynamic> data,
  }) {
    final ts = data['createdAt'];
    DateTime created;
    if (ts is Timestamp) {
      created = ts.toDate();
    } else {
      created = DateTime.now();
    }

    return BankAccountModel(
      id: id,
      iban: (data['iban'] ?? '').toString(),
      isDefault: (data['isDefault'] ?? false) as bool,
      createdAt: created,
    );
  }
}