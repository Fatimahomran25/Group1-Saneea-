class FreelancerProfileModel {
  final String uid;
  final String nationalId;
  final double rating;

  final String name;
  final String title;
  final String email;
  final String bio;
  final String? photoUrl;

  final String? serviceType;
 final String? workingMode; 

  final String? iban;

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
    required this.iban,
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
  bool clearServiceType = false,
  String? workingMode,
  bool clearWorkingMode = false,
  String? iban,
  List<ExperienceModel>? experiences,
  List<String>? portfolioUrls,
}) {
  return FreelancerProfileModel(
    uid: uid,
    nationalId: nationalId,
    rating: rating,
    name: name ?? this.name,
    title: title ?? this.title,
    email: email ?? this.email,
    bio: bio ?? this.bio,
    photoUrl: photoUrl ?? this.photoUrl,
    serviceType: clearServiceType ? null : (serviceType ?? this.serviceType),
    workingMode: clearWorkingMode ? null : (workingMode ?? this.workingMode),
    iban: iban ?? this.iban,
    experiences: experiences ?? this.experiences,
    portfolioUrls: portfolioUrls ?? this.portfolioUrls,
  );
}

  factory FreelancerProfileModel.fromFirestore({
    required String uid,
    required Map<String, dynamic>? data,
    required double rating,
  }) {
    data ??= {};
    final portRaw = data['portfolioUrls'];
    final ports = (portRaw is List)
    ? portRaw.map((e) => e.toString()).toList()
    : <String>[];  
    return FreelancerProfileModel(
      uid: uid,
      nationalId: data['nationalId'] ?? '',
      rating: rating,
      name: data['name'] ?? '',
      title: data['title'] ?? '',
      email: data['email'] ?? '',
      bio: data['bio'] ?? '',
      photoUrl: data['photoUrl'],
      serviceType: data['serviceType'] as String?,
      workingMode: data['workingMode'] as String?,
      iban: data['iban'],
      experiences: [],
      portfolioUrls: ports,
    );
  }
}

class ExperienceModel {
  final String field;
  final String org;
  final String period;

  const ExperienceModel({
    required this.field,
    required this.org,
    required this.period,
  });

  Map<String, dynamic> toMap() {
    return {
      'field': field,
      'org': org,
      'period': period,
    };
  }

  factory ExperienceModel.fromMap(Map<String, dynamic> map) {
    return ExperienceModel(
      field: map['field'] ?? '',
      org: map['org'] ?? '',
      period: map['period'] ?? '',
    );
  }
}