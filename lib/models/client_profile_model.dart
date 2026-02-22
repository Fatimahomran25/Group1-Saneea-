class ClientProfileModel {
  final String uid;
  final String nationalId; // read-only
  final String name;       // editable
  final String email;      // editable (gmail)
  final String bio;        // editable (<=150)
  final String? photoUrl;  // editable (from Storage)
  final double rating;     // read-only (computed from reviews)
  final String roleLabel;  // "Client"

  const ClientProfileModel({
    required this.uid,
    required this.nationalId,
    required this.name,
    required this.email,
    required this.bio,
    required this.photoUrl,
    required this.rating,
    this.roleLabel = "Client",
  });

  ClientProfileModel copyWith({
    String? nationalId,
    String? name,
    String? email,
    String? bio,
    String? photoUrl,
    double? rating,
    String? roleLabel,
  }) {
    return ClientProfileModel(
      uid: uid,
      nationalId: nationalId ?? this.nationalId,
      name: name ?? this.name,
      email: email ?? this.email,
      bio: bio ?? this.bio,
      photoUrl: photoUrl ?? this.photoUrl,
      rating: rating ?? this.rating,
      roleLabel: roleLabel ?? this.roleLabel,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nationalId': nationalId,
      'name': name,
      'email': email,
      'bio': bio,
      'photoUrl': photoUrl,
      'accountType': 'client',
    };
  }

  static ClientProfileModel fromFirestore({
    required String uid,
    required Map<String, dynamic> data,
    double rating = 0,
  }) {
    final firstName = (data['firstName'] ?? '').toString().trim();
    final lastName = (data['lastName'] ?? '').toString().trim();

    // إذا مشروعك يستخدم first/lastName نخليه يتجمّع تلقائيًا
    final composedName =
        (data['name'] ?? '$firstName $lastName').toString().trim();

    return ClientProfileModel(
      uid: uid,
      nationalId: (data['nationalId'] ?? '').toString(),
      name: composedName.isEmpty ? "Client" : composedName,
      email: (data['email'] ?? '').toString(),
      bio: (data['bio'] ?? '').toString(),
      photoUrl: data['photoUrl']?.toString(),
      rating: rating,
      roleLabel: "Client",
    );
  }
}

class ClientReviewModel {
  final String reviewerName;
  final int rating; // 1..5
  final String text;

  const ClientReviewModel({
    required this.reviewerName,
    required this.rating,
    required this.text,
  });

  static ClientReviewModel fromFirestore(Map<String, dynamic> data) {
    return ClientReviewModel(
      reviewerName: (data['reviewerName'] ?? 'User').toString(),
      rating: (data['rating'] ?? 0) as int,
      text: (data['text'] ?? '').toString(),
    );
  }
}
