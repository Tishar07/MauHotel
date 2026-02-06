import 'package:flutter/material.dart';
import '../models/review_model.dart';
import '../accessibility/accessibility_state.dart';

class ReviewTile extends StatelessWidget {
  final Review review;

  const ReviewTile({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    final int fullStars = review.rating.floor();
    final bool hasHalfStar = (review.rating - fullStars) >= 0.5;
    final bool highContrast = AccessibilityState.contrast.value >= 2;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=7'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---------- USER ----------
                Text(
                  'User ${review.userId.substring(0, 6)}',
                  style: TextStyle(
                    color: highContrast ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                // ---------- STARS ----------
                Row(
                  children: List.generate(5, (index) {
                    if (index < fullStars) {
                      return const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 18,
                      );
                    } else if (index == fullStars && hasHalfStar) {
                      return const Icon(
                        Icons.star_half,
                        color: Colors.amber,
                        size: 18,
                      );
                    } else {
                      return const Icon(
                        Icons.star_border,
                        color: Colors.amber,
                        size: 18,
                      );
                    }
                  }),
                ),

                const SizedBox(height: 4),

                // ---------- COMMENT ----------
                Text(
                  review.comment,
                  style: TextStyle(
                    color: highContrast ? Colors.white : Colors.black87,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 4),

                // ---------- DATE ----------
                Text(
                  review.reviewDate,
                  style: TextStyle(
                    fontSize: 12,
                    color: highContrast ? Colors.white70 : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
