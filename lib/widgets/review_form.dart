import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/model/review.dart';
import '/provider/review_provider.dart';

class ReviewForm extends StatefulWidget {
  final String productId;

  const ReviewForm({required this.productId});

  @override
  _ReviewFormState createState() => _ReviewFormState();
}

class _ReviewFormState extends State<ReviewForm> {
  final _usernameController = TextEditingController();
  final _commentController = TextEditingController();
  double _rating = 3.0;

  @override
  Widget build(BuildContext context) {
    final reviewProvider = Provider.of<ReviewProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text("Write a Review")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: "Your Name"),
            ),
            TextField(
              controller: _commentController,
              decoration: const InputDecoration(labelText: "Your Review"),
            ),
            Slider(
              value: _rating,
              min: 1,
              max: 5,
              divisions: 4,
              label: _rating.toString(),
              onChanged: (value) {
                setState(() {
                  _rating = value;
                });
              },
            ),
            ElevatedButton(
              onPressed: () async {
                final userId = _usernameController.text.trim();
                final reviewText = _commentController.text.trim();

                if (userId.isEmpty || reviewText.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please fill in all fields")),
                  );
                  return;
                }

                try {
                  print('Submitting review: $userId, $_rating, $reviewText for product ${widget.productId}');
                  await reviewProvider.addReview(
                    widget.productId,
                    userId,
                    _rating,
                    reviewText,
                  );
                  print('Review submitted successfully');
                  Navigator.pop(context);
                } catch (e) {
                  print('Error submitting review: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Failed to submit review: $e")),
                  );
                }
              },
              child: const Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _commentController.dispose();
    super.dispose();
  }
}