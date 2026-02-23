

class ReviewModel {
  final String reviewerName;
  final int rating; // 1..5
  final String text;

  const ReviewModel({
    required this.reviewerName,
    required this.rating,
    required this.text,
  });

  factory ReviewModel.fromFirestore(Map<String, dynamic> data) {
    final r = data['rating'];
    final ratingInt = (r is int) ? r : (r is num ? r.toInt() : 0);

    return ReviewModel(
      reviewerName: (data['reviewerName'] ?? 'User').toString(),
      rating: ratingInt.clamp(0, 5),
      text: (data['text'] ?? '').toString(),
    );
  }
}