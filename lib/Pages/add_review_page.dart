import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';
import '../accessibility/accessibility_state.dart';

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
        SnackBar(
          content: Text(
            AccessibilityState.t(
              'Please give a rating and write a comment',
              'Veuillez donner une note et écrire un commentaire',
            ),
          ),
        ),
      );
      return;
    }

    final user = supabase.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AccessibilityState.t(
              'You must be logged in to submit a review',
              'Vous devez être connecté pour soumettre un avis',
            ),
          ),
        ),
      );
      return;
    }

    setState(() => _submitting = true);

    try {
      await supabase.from('reviews').insert({
        'hotel_id': widget.hotelId,
        'rating': _rating.toInt(),
        'comment': _commentController.text.trim(),
        'review_date': DateTime.now().toIso8601String(),
        'user_id': user.id,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AccessibilityState.t(
              'Review submitted successfully!',
              'Avis soumis avec succès !',
            ),
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AccessibilityState.t(
              'Error submitting review: $e',
              'Erreur lors de la soumission de l\'avis : $e',
            ),
          ),
        ),
      );
    } finally {
      setState(() => _submitting = false);
    }
  }

  Widget _buildStarRating(bool highContrast) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starIndex = index + 1;
        return IconButton(
          icon: Icon(
            Icons.star,
            color: _rating >= starIndex
                ? Colors.amber
                : (highContrast ? Colors.white70 : Colors.grey[300]),
            size: 36,
          ),
          onPressed: () => setState(() => _rating = starIndex.toDouble()),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AccessibilityState.rebuild,
      builder: (context, _) {
        final highContrast = AccessibilityState.contrast.value >= 2;

        return Scaffold(
          backgroundColor: highContrast ? Colors.black : Colors.white,
          appBar: AppBar(
            title: Text(
              AccessibilityState.t('Add Review', 'Ajouter un avis'),
              style: TextStyle(
                color: highContrast ? Colors.white : Colors.black,
              ),
            ),
            backgroundColor: highContrast ? Colors.black : Colors.white,
            iconTheme: IconThemeData(
              color: highContrast ? Colors.white : Colors.black,
            ),
          ),
          body: SingleChildScrollView(
            padding: AccessibilityState.padding(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AccessibilityState.t('Your Rating', 'Votre note'),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: highContrast ? Colors.white : Colors.black,
                  ),
                ),
                _buildStarRating(highContrast),
                SizedBox(height: AccessibilityState.gap(20)),
                TextField(
                  controller: _commentController,
                  maxLines: 5,
                  style: TextStyle(
                    color: highContrast ? Colors.white : Colors.black87,
                  ),
                  decoration: InputDecoration(
                    labelText: AccessibilityState.t(
                      'Your Comment',
                      'Votre commentaire',
                    ),
                    labelStyle: TextStyle(
                      color: highContrast ? Colors.white70 : Colors.black54,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: highContrast ? Colors.white70 : Colors.grey,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: AccessibilityState.gap(30)),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitting ? null : _submitReview,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: _submitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            AccessibilityState.t(
                              'Submit Review',
                              'Soumettre l\'avis',
                            ),
                            style: const TextStyle(
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
      },
    );
  }
}
