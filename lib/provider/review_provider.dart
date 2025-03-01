// /provider/review_provider.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import '/model/review.dart';

class ReviewProvider with ChangeNotifier {
  List<Review> _reviews = [];

  List<Review> getReviewsByProduct(String productId) {
    return _reviews.where((review) => review.productId == productId).toList();
  }

  double getAverageRating(String productId) {
    final productReviews = getReviewsByProduct(productId);
    if (productReviews.isEmpty) return 0.0;
    return productReviews.map((r) => r.rating).reduce((a, b) => a + b) / productReviews.length;
  }

  Future<void> loadReviews() async {
  await Future.delayed(const Duration(seconds: 1));
  _reviews = [
    Review(
      id: DateTime.now().toString(),
      productId: "default_product",
      userId: "User1",
      rating: 4.5,
      reviewText: "Great product!",
      timestamp: DateTime.now(),
      imageUrl: "https://example.com/image.jpg", // ตัวอย่าง URL
    ),
    // เพิ่มข้อมูลทดสอบเพิ่มเติมตามต้องการ
  ];
  notifyListeners();
}

  Future<void> addReview(String productId, String userId, double rating, String reviewText) async {
    final newReview = Review(
      id: DateTime.now().toString(),
      productId: productId,
      userId: userId,
      rating: rating,
      reviewText: reviewText,
      timestamp: DateTime.now(),
    );
    _reviews.add(newReview);
    notifyListeners();
  }

  Future<void> addReviewWithImage(
    String productId,
    String userId,
    double rating,
    String reviewText,
    dynamic image,
  ) async {
    String? imageUrl;
    if (image != null) {
      if (image is File) {
        imageUrl = image.path; // หรืออัปโหลดและได้ URL
      } else if (image is String) {
        imageUrl = image;
      }
    }

    final newReview = Review(
      id: DateTime.now().toString(),
      productId: productId,
      userId: userId,
      rating: rating,
      reviewText: reviewText,
      timestamp: DateTime.now(),
      imageUrl: imageUrl,
    );
    _reviews.add(newReview);
    notifyListeners();
  }

  void deleteReview(String reviewId) {
    _reviews.removeWhere((review) => review.id == reviewId);
    notifyListeners();
  }
}