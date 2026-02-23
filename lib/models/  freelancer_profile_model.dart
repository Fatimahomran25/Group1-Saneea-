class ExperienceModel {
  final String field;
  final String org;
  final String period;

  const ExperienceModel({required this.field, required this.org, required this.period});

  Map<String, dynamic> toMap() => {'field': field, 'org': org, 'period': period};

  factory ExperienceModel.fromMap(Map<String, dynamic> m) => ExperienceModel(
        field: (m['field'] ?? '').toString(),
        org: (m['org'] ?? '').toString(),
        period: (m['period'] ?? '').toString(),
      );
}

class FreelancerProfileModel {
  final String uid;
  final String nationalId;
  final double rating; // computed

  final String name;
  final String title;
  final String email;
  final String bio; // <=150
  final String? photoUrl;

  final String serviceType; // one-time/part-time/full-time
  final String workingMode; // in person/remote/hybrid

  final List<ExperienceModel> experiences;
  final List<String> portfolioUrls;

  const FreelancerProfileModel({
    required this.uid,
    required this.nationalId,
    required this.rating,
    required this.name,
    required this.title,
    required this.email,
    required this.bio,
    required this.photoUrl,
    required this.serviceType,
    required this.workingMode,
    required this.experiences,
    required this.portfolioUrls,
  });

  FreelancerProfileModel copyWith({
    String? name,
    String? title,
    String? email,
    String? bio,
    String? photoUrl,
    String? serviceType,
    String? workingMode,
    List<ExperienceModel>? experiences,
    List<String>? portfolioUrls,
    double? rating,
  }) {
    return FreelancerProfileModel(
      uid: uid,
      nationalId: nationalId,
      rating: rating ?? this.rating,
      name: name ?? this.name,
      title: title ?? this.title,
      email: email ?? this.email,
      bio: bio ?? this.bio,
      photoUrl: photoUrl ?? this.photoUrl,
      serviceType: serviceType ?? this.serviceType,
      workingMode: workingMode ?? this.workingMode,
      experiences: experiences ?? this.experiences,
      portfolioUrls: portfolioUrls ?? this.portfolioUrls,
    );
  }

  factory FreelancerProfileModel.fromFirestore({
    required String uid,
    required Map<String, dynamic> data,
    required double rating,
  }) {
    final exps = (data['experiences'] as List<dynamic>?)
            ?.map((e) => ExperienceModel.fromMap(Map<String, dynamic>.from(e)))
            .toList() ??
        <ExperienceModel>[];

    final urls = (data['portfolioUrls'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? <String>[];

    return FreelancerProfileModel(
      uid: uid,
      nationalId: (data['nationalId'] ?? '').toString(),
      rating: rating,
      name: (data['name'] ?? '').toString(),
      title: (data['title'] ?? '').toString(),
      email: (data['email'] ?? '').toString(),
      bio: (data['bio'] ?? '').toString(),
      photoUrl: data['photoUrl']?.toString(),
      serviceType: (data['serviceType'] ?? 'one-time').toString(),
      workingMode: (data['workingMode'] ?? 'in person').toString(),
      experiences: exps,
      portfolioUrls: urls,
    );
  }
}

class BankAccountModel {
  final String id;
  final String iban;
  final String bankName;

  const BankAccountModel({required this.id, required this.iban, required this.bankName});

  Map<String, dynamic> toMap() => {'iban': iban, 'bankName': bankName};

  factory BankAccountModel.fromDoc(String id, Map<String, dynamic> data) => BankAccountModel(
        id: id,
        iban: (data['iban'] ?? '').toString(),
        bankName: (data['bankName'] ?? '').toString(),
      );
}