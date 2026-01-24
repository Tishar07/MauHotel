import 'package:flutter/material.dart';
import '../models/review_model.dart';
import '../theme/app_theme.dart';
import 'review_tile.dart';

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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------- TITLE ----------
            if (showTitle)
              const Text(
                'Ratings & Reviews',
                style: TextStyle(
                  color: AppTheme.primaryBlue,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

            if (showTitle) const SizedBox(height: 8),

            // ---------- LOADING ----------
            if (isLoading) const Center(child: CircularProgressIndicator()),

            // ---------- EMPTY ----------
            if (!isLoading && reviews.isEmpty)
              const Text(
                'No reviews yet. Be the first to review this hotel!',
                style: TextStyle(color: Colors.grey),
              ),

            // ---------- RATING + REVIEWS ----------
            if (!isLoading && reviews.isNotEmpty) ...[
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(
                    '${averageRating.toStringAsFixed(1)} / 5.0',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '(${reviews.length} reviews)',
                    style: const TextStyle(color: Colors.grey),
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
