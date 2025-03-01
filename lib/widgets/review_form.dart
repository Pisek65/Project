import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import '/provider/review_provider.dart';
import '/model/review.dart';

class ReviewForm extends StatefulWidget {
  final String productId;
  final Review? reviewToEdit;

  const ReviewForm({required this.productId, this.reviewToEdit, Key? key}) : super(key: key);

  @override
  _ReviewFormState createState() => _ReviewFormState();
}

class _ReviewFormState extends State<ReviewForm> {
  late final TextEditingController _usernameController;
  late final TextEditingController _commentController;
  late double _rating;
  File? _image;
  String? _imageUrl;
  bool _isSubmitting = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.reviewToEdit?.userId ?? '');
    _commentController = TextEditingController(text: widget.reviewToEdit?.reviewText ?? '');
    _rating = widget.reviewToEdit?.rating ?? 3.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.reviewToEdit == null ? "Write a Review" : "Edit Review"),
        backgroundColor: const Color.fromARGB(255, 31, 203, 255),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(
              controller: _usernameController,
              label: "Your Name",
              icon: Icons.person,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _commentController,
              label: "Your Review",
              icon: Icons.comment,
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 300,
              child: Center(child: _buildImagePicker()),
            ),
            const SizedBox(height: 20),
            _buildRatingSlider(),
            const SizedBox(height: 30),
            _isSubmitting
                ? const Center(child: CircularProgressIndicator())
                : _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color.fromARGB(255, 25, 48, 247)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color.fromARGB(255, 13, 231, 251), width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          "Add Image",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 25, 48, 247),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 300),
          child: _image == null && _imageUrl == null
              ? Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: const Center(
                    child: Text(
                      "No image selected",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ),
                )
              : kIsWeb
                  ? Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: _imageUrl != null
                            ? Image.network(
                                _imageUrl!,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  print("Image network load error: $error");
                                  return const Center(
                                    child: Text(
                                      "Error loading image",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  );
                                },
                              )
                            : const Center(
                                child: Text(
                                  "No image URL",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _image!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            print("Image file load error: $error");
                            return const Center(
                              child: Text(
                                "Error loading image",
                                style: TextStyle(color: Colors.red),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: _pickImage,
          icon: const Icon(Icons.image, color: Colors.white),
          label: const Text(
            "Pick Image",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 25, 48, 247),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 5,
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    try {
      if (kIsWeb) {
        final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
        if (pickedFile != null && mounted) {
          print("Image picked (Web): ${pickedFile.path}");
          setState(() {
            _imageUrl = pickedFile.path;
            _image = null; // ล้าง File สำหรับ Web
          });
        }
      } else {
        final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
        if (image != null && mounted) {
          print("Image picked (Mobile): ${image.path}");
          setState(() {
            _image = File(image.path);
            _imageUrl = null; // ล้าง URL สำหรับ Mobile
          });
        }
      }
    } catch (e) {
      print("Pick image error: $e");
      _showSnackbar("Failed to pick image: $e", Colors.red);
    }
  }

  Widget _buildRatingSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Rating", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Slider(
          value: _rating,
          min: 1,
          max: 5,
          divisions: 4,
          label: _rating.toString(),
          activeColor: const Color.fromARGB(255, 36, 62, 236),
          inactiveColor: const Color.fromARGB(255, 24, 165, 253),
          onChanged: (value) {
            setState(() {
              _rating = value;
            });
          },
        ),
        Center(
          child: Text(
            _rating.toStringAsFixed(1),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _submitReview,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 72, 53, 246),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text(
          "Submit Review",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  Future<void> _submitReview() async {
  final userId = _usernameController.text.trim();
  final reviewText = _commentController.text.trim();

  if (userId.isEmpty || reviewText.isEmpty) {
    _showSnackbar("Please fill in all fields", Colors.red);
    return;
  }

  setState(() {
    _isSubmitting = true;
  });

  try {
    final reviewProvider = Provider.of<ReviewProvider>(context, listen: false);
    print("Submitting review with image: ${_image?.path ?? _imageUrl}");
    if (widget.reviewToEdit == null) {
      await reviewProvider.addReviewWithImage(
        widget.productId,
        userId,
        _rating,
        reviewText,
        kIsWeb ? _imageUrl : _image?.path,
      );
    } else {
      reviewProvider.deleteReview(widget.reviewToEdit!.id);
      await reviewProvider.addReviewWithImage(
        widget.productId,
        userId,
        _rating,
        reviewText,
        kIsWeb ? _imageUrl : _image?.path,
      );
    }
    _showSnackbar("Review submitted successfully!", Colors.green);
    Navigator.pop(context, true);
  } catch (e) {
    print("Submit review error: $e");
    _showSnackbar("Failed to submit review: $e", Colors.red);
  } finally {
    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });
    }
  }
}

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
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