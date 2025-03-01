import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '/provider/review_provider.dart';
import '/model/review.dart';
import '../widgets/review_card.dart';
import '../widgets/review_form.dart';

class ProductPage extends StatelessWidget {
  final String productId;

  const ProductPage({required this.productId, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "Product Reviews",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            shadows: [Shadow(color: Colors.black26, blurRadius: 4)],
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<ReviewProvider>().loadReviews(),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade900, Colors.blue.shade300],
          ),
        ),
        child: SafeArea(
          child: FutureBuilder(
            future: context.read<ReviewProvider>().loadReviews(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildLoadingEffect();
              }
              return Consumer<ReviewProvider>(
                builder: (context, reviewProvider, child) {
                  final List<Review> reviews =
                      reviewProvider.getReviewsByProduct(productId);
                  return Column(
                    children: [
                      _buildAverageRating(reviewProvider, productId),
                      Expanded(
                        child: reviews.isEmpty
                            ? _buildEmptyReviews()
                            : ListView.builder(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                itemCount: reviews.length,
                                itemBuilder: (context, index) {
                                  final Review currentReview = reviews[index];
                                  return AnimatedReviewCard(
                                    review: currentReview,
                                    index: index,
                                    onDelete: () {
                                      reviewProvider
                                          .deleteReview(currentReview.id);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: const Text(
                                            "Review deleted",
                                            style: TextStyle(color: Color.fromARGB(255, 245, 243, 243)),
                                          ),
                                          backgroundColor: const Color.fromARGB(255, 244, 1, 1),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    },
                                    onEdit: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ReviewForm(
                                            productId: productId,
                                            reviewToEdit: currentReview,
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ReviewForm(productId: productId)),
        ),
        backgroundColor: Colors.amber.shade700,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildAverageRating(ReviewProvider provider, String productId) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.star, color: Colors.yellow, size: 30),
            const SizedBox(width: 8),
            Text(
              "Average Rating: ${provider.getAverageRating(productId).toStringAsFixed(1)}",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyReviews() {
    return const Center(
      child: Text(
        "No reviews yet!",
        style: TextStyle(
          fontSize: 18,
          color: Colors.white70,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _buildLoadingEffect() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.white,
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        );
      },
    );
  }
}

class AnimatedReviewCard extends StatelessWidget {
  final Review review;
  final int index;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const AnimatedReviewCard({
    required this.review,
    required this.index,
    required this.onDelete,
    required this.onEdit,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      transform:
          Matrix4.translationValues(0, index * 8 < 50 ? 0 : 50 - index * 8, 0),
      child: ReviewCard(
        review: review,
        onDelete: onDelete,
        onEdit: onEdit,
      ),
    );
  }
}
