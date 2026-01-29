import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddReviewPage extends StatefulWidget {
  final int hotelId;

  const AddReviewPage({Key? key, required this.hotelId}) : super(key: key);

  @override
  State<AddReviewPage> createState() => _AddReviewPageState();
}

class _AddReviewPageState extends State<AddReviewPage> {
  final supabase = Supabase.instance.client;
  double _rating = 0;
  final _commentController = TextEditingController();
  bool _submitting = false;

  Future<void> _submitReview() async {
    if (_rating == 0 || _commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please give a rating and write a comment')),
      );
      return;
    }

    setState(() => _submitting = true);
    final user = supabase.auth.currentUser;

    try {
      await supabase.from('reviews').insert({
        'hotel_id': widget.hotelId,
        'rating': _rating.toInt(),
        'comment': _commentController.text.trim(),
        'review_date': DateTime.now().toIso8601String(),
        'user_id': user!.id,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review submitted successfully!')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting review: $e')),
      );
    } finally {
      setState(() => _submitting = false);
    }
  }

  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starIndex = index + 1;
        return IconButton(
          icon: Icon(
            Icons.star,
            color: _rating >= starIndex ? Colors.amber : Colors.grey[300],
            size: 36,
          ),
          onPressed: () => setState(() => _rating = starIndex.toDouble()),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Review'),
        backgroundColor: const Color.fromRGBO(21, 101, 192, 1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Rating',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            _buildStarRating(),
            const SizedBox(height: 20),
            TextField(
              controller: _commentController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Your Comment',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(21, 101, 192, 1),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: _submitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : const Text(
                        'Submit Review',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
