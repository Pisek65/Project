class Review {
  final String id;
  final String productId;
  final String userId;
  final double rating;
  final String reviewText;
  final DateTime timestamp;
  final String? imageUrl;

  Review({
    required this.id,
    required this.productId,
    required this.userId,
    required this.rating,
    required this.reviewText,
    required this.timestamp,
    this.imageUrl,
  });
}