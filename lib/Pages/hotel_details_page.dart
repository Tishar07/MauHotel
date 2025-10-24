import 'package:flutter/material.dart';
import 'dart:math';
import '../models/hotel_model.dart';

class HotelDetailsPage extends StatefulWidget {
  final Hotel hotel;

  const HotelDetailsPage({super.key, required this.hotel});

  @override
  State<HotelDetailsPage> createState() => _HotelDetailsPageState();
}

class _HotelDetailsPageState extends State<HotelDetailsPage> {
  bool isLoved = false;

  final int fakeReviewCount = 1000 + Random().nextInt(500);
  final double fakeRating = (4.0 + Random().nextDouble()).clamp(4.0, 5.0);

  IconData getAmenityIcon(String amenity) {
    switch (amenity.toLowerCase()) {
      case 'free wifi':
      case 'wifi':
        return Icons.wifi;
      case 'swimming pool':
      case 'pool':
        return Icons.pool;
      case 'spa':
        return Icons.spa;
      case 'private pool':
        return Icons.water;
      case 'yoga classes':
        return Icons.self_improvement;
      case 'beach access':
        return Icons.beach_access;
      case 'butler services':
        return Icons.room_service;
      case 'rooftop bar':
        return Icons.room_service;
      case 'restaurant':
        return Icons.restaurant;
      default:
        return Icons.check_circle_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hotel = widget.hotel;

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Image with Blue Overlay and Action Buttons
                Stack(
                  children: [
                    Image.network(
                      hotel.imageUrl,
                      height: 300,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Container(
                      height: 300,
                      width: double.infinity,
                      color: Colors.blue.withOpacity(0.3),
                    ),
                    Positioned(
                      top: 40,
                      left: 16,
                      child: CircleAvatar(
                        backgroundColor: Colors.white70,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 40,
                      right: 16,
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.white70,
                            child: IconButton(
                              icon: const Icon(Icons.share),
                              onPressed: () {
                                // TODO: Share logic
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          CircleAvatar(
                            backgroundColor: Colors.white70,
                            child: IconButton(
                              icon: Icon(
                                isLoved
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isLoved ? Colors.red : Colors.black,
                              ),
                              onPressed: () {
                                setState(() {
                                  isLoved = !isLoved;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Hotel Name & Location
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hotel.name,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 18,
                            color: Color.fromARGB(255, 240, 0, 0),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            hotel.location,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Price & Book Now
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rs ${hotel.pricePerNight.toStringAsFixed(2)} / night',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Total includes taxes & fees',
                        style: TextStyle(
                          color: const Color.fromARGB(255, 255, 0, 0),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          // TODO: Booking logic
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            22,
                            98,
                            211,
                          ),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Book Now',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Amenities Logos (Horizontal Row with Symmetrical Spacing)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Wrap(
                    direction: Axis.horizontal,
                    spacing: 32, // horizontal spacing between items
                    runSpacing: 24, // vertical spacing if wrapped
                    children: hotel.amenities.map((amenity) {
                      return SizedBox(
                        width: 100, // fixed width for symmetry
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              getAmenityIcon(amenity),
                              color: const Color.fromARGB(255, 17, 108, 212),
                              size: 28,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              amenity,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 12),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),

                // About Hotel
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'About this hotel',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        hotel.description,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Ratings & Reviews
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ratings & Reviews',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              '${fakeRating.toStringAsFixed(1)} / 5.0',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '(${fakeReviewCount} reviews)',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Review 1
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const CircleAvatar(
                              radius: 24,
                              backgroundImage: NetworkImage(
                                'https://i.pravatar.cc/150?img=3',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Alicia R.',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Row(
                                    children: List.generate(5, (index) {
                                      return const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 18,
                                      );
                                    }),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Absolutely loved the private pool and spa! The staff were incredibly attentive and the beach access made our mornings magical.',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Review 2
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const CircleAvatar(
                              radius: 24,
                              backgroundImage: NetworkImage(
                                'https://i.pravatar.cc/150?img=5',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Dev M.',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Row(
                                    children: List.generate(4, (index) {
                                      return const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 18,
                                      );
                                    }),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'The yoga classes were a peaceful escape and the butler service was top-notch. Would definitely come back!',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Bottom Compare Button
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Compare logic
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 28, 114, 194),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Compare Similar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
