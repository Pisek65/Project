// lib/model/review.dart
class Review {
  final String id;
  final String productId;
  final String userId;
  final double rating;
  final String reviewText;
  final DateTime timestamp;

  Review({
    required this.id,
    required this.productId,
    required this.userId,
    required this.rating,
    required this.reviewText,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "productId": productId,
      "userId": userId,
      "rating": rating,
      "reviewText": reviewText,
      "timestamp": timestamp.toIso8601String(),
    };
  }

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json["id"] as String,
      productId: json["productId"] as String,
      userId: json["userId"] as String,
      rating: (json["rating"] as num).toDouble(),
      reviewText: json["reviewText"] as String,
      timestamp: DateTime.parse(json["timestamp"] as String),
    );
  }
}