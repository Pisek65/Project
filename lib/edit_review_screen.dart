import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import '/model/review.dart';

class ReviewProvider with ChangeNotifier {
  static const String dbName = "reviews.db";
  Database? _db;
  final _store = intMapStoreFactory.store("reviews");
  final List<Review> _reviews = [];

  Future<Database> get database async {
    if (_db != null) return _db!;
    try {
      Directory appDir = await getApplicationDocumentsDirectory();
      String dbLocation = join(appDir.path, dbName);
      _db = await databaseFactoryIo.openDatabase(dbLocation);
      return _db!;
    } catch (e) {
      print('❌ Error opening database: $e');
      rethrow;
    }
  }

  List<Review> get reviews => List.unmodifiable(_reviews);

  List<Review> getReviewsByProduct(String productId) =>
      _reviews.where((review) => review.productId == productId).toList();

 double getAverageRating(String productId) {
  final productReviews = getReviewsByProduct(productId);
  if (productReviews.isEmpty) return 0.0; // ป้องกันการหารด้วย 0

  double totalRating = productReviews.fold(0.0, (sum, item) => sum + item.rating);
  return totalRating / productReviews.length;
}

  Future<void> loadReviews() async {
    try {
      final db = await database;
      final snapshot = await _store.find(db);
      _reviews.clear();
      _reviews.addAll(snapshot.map((record) {
        final data = record.value as Map<String, dynamic>;
        return Review(
          id: record.key.toString(),
          productId: data['productId'] ?? 'unknown_product',
          userId: data['userId'] ?? 'unknown_user',
          rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
          reviewText: data['reviewText'] ?? '',
          timestamp: DateTime.tryParse(data['timestamp'] ?? '') ?? DateTime.now(),
        );
      }));
      notifyListeners();
    } catch (e) {
      print('❌ Error loading reviews: $e');
    }
  }

  Future<void> addReview(String productId, String userId, double rating, String reviewText) async {
    try {
      final db = await database;
      final newReview = {
        "productId": productId,
        "userId": userId,
        "rating": rating,
        "reviewText": reviewText,
        "timestamp": DateTime.now().toIso8601String(),
      };
      final key = await _store.add(db, newReview);
      _reviews.add(Review(
        id: key.toString(),
        productId: productId,
        userId: userId,
        rating: rating,
        reviewText: reviewText,
        timestamp: DateTime.now(),
      ));
      notifyListeners();
    } catch (e) {
      print('❌ Error adding review: $e');
      rethrow;
    }
  }

  Future<void> deleteReview(String id) async {
    try {
      final db = await database;
      final intId = int.tryParse(id);
      if (intId == null) return;
      await _store.record(intId).delete(db);
      _reviews.removeWhere((review) => review.id == id);
      notifyListeners();
    } catch (e) {
      print('❌ Error deleting review: $e');
    }
  }

  Future<void> updateReview(String id, double rating, String reviewText) async {
    try {
      final db = await database;
      final intId = int.tryParse(id);
      if (intId == null) return;
      final updatedData = {
        "rating": rating,
        "reviewText": reviewText,
        "timestamp": DateTime.now().toIso8601String(),
      };
      await _store.record(intId).update(db, updatedData);
      final index = _reviews.indexWhere((review) => review.id == id);
      if (index != -1) {
        _reviews[index] = Review(
          id: id,
          productId: _reviews[index].productId,
          userId: _reviews[index].userId,
          rating: rating,
          reviewText: reviewText,
          timestamp: DateTime.now(),
        );
        notifyListeners();
      }
    } catch (e) {
      print('❌ Error updating review: $e');
    }
  }

  Future<void> closeDatabase() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
  }
}
