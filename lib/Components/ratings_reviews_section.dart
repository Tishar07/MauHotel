import 'package:flutter/material.dart';
import '../models/review_model.dart';
import '../theme/app_theme.dart';
import 'review_tile.dart';
import '../accessibility/accessibility_state.dart';

class RatingsReviewsSection extends StatelessWidget {
  final bool isLoading;
  final List<Review> reviews;
  final bool showReviews;
  final bool showTitle;

  const RatingsReviewsSection({
    super.key,
    required this.isLoading,
    required this.reviews,
    this.showReviews = true,
    this.showTitle = true,
  });

  double get averageRating {
    if (reviews.isEmpty) return 0.0;
    return reviews.fold(0.0, (sum, r) => sum + r.rating) / reviews.length;
  }

  @override
  Widget build(BuildContext context) {
    final highContrast = AccessibilityState.contrast.value >= 2;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: highContrast
              ? Colors.black
              : Colors.white, // high contrast background
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------- TITLE ----------
            if (showTitle)
              Text(
                AccessibilityState.t(
                  'Ratings & Reviews', // English
                  'Notes et Avis', // French
                ),
                style: TextStyle(
                  color: highContrast ? Colors.white : AppTheme.primaryBlue,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

            if (showTitle) const SizedBox(height: 8),

            // ---------- LOADING ----------
            if (isLoading)
              Center(
                child: CircularProgressIndicator(
                  color: highContrast ? Colors.white : AppTheme.primaryBlue,
                ),
              ),

            // ---------- EMPTY ----------
            if (!isLoading && reviews.isEmpty)
              Text(
                AccessibilityState.t(
                  'No reviews yet. Be the first to review this hotel!', // English
                  'Pas encore d’avis. Soyez le premier à évaluer cet hôtel !', // French
                ),
                style: TextStyle(
                  color: highContrast ? Colors.white70 : Colors.grey,
                ),
              ),

            // ---------- RATING + REVIEWS ----------
            if (!isLoading && reviews.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(
                    '${averageRating.toStringAsFixed(1)} / 5.0',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: highContrast ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 8),

                  Text(
                    AccessibilityState.t(
                      '(${reviews.length} review${reviews.length == 1 ? '' : 's'})',
                      '(${reviews.length} avis)',
                    ),
                    style: TextStyle(
                      fontSize: 13,
                      color: highContrast ? Colors.white : Colors.grey.shade700,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),

              if (showReviews) ...[
                const SizedBox(height: 16),
                ...reviews.map((r) => ReviewTile(review: r)),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
