import 'package:flutter/material.dart';
import '../services/supabase_service.dart'; //
import '../models/hotel_model.dart'; // your hotel model
import 'booking_page.dart';

import 'dart:math';
import '../models/hotel_model.dart';
import '../services/supabase_service.dart';

class HotelViewPage extends StatefulWidget {
  final String hotelId;

  const HotelViewPage({Key? key, required this.hotelId}) : super(key: key);

  @override
  State<HotelViewPage> createState() => _HotelViewPageState();
}

class _HotelViewPageState extends State<HotelViewPage> {
  late Future<Hotel> hotelFuture;
  bool isLoved = false;
  final int fakeReviewCount = 800 + Random().nextInt(300);
  final double fakeRating = (4.0 + Random().nextDouble()).clamp(4.0, 5.0);

  @override
  void initState() {
    super.initState();
    hotelFuture = SupabaseService().getHotelById(widget.hotelId);
  }

  IconData getAmenityIcon(String amenity) {
    switch (amenity.toLowerCase()) {
      case 'free wifi':
      case 'wifi':
        return Icons.wifi;
      case 'pool':
      case 'swimming pool':
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
      case 'restaurant':
        return Icons.restaurant;
      default:
        return Icons.check_circle_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Hotel>(
        future: hotelFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Hotel not found'));
          }

          final hotel = snapshot.data!;
          return SafeArea(child: buildHotelUI(hotel));
        },
      ),
    );
  }

  Widget buildHotelUI(Hotel hotel) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🏞️ Top image with overlay
              Stack(
                children: [
                  Image.network(
                    hotel.imageUrl,
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Container(height: 300, color: Colors.blue.withOpacity(0.3)),
                  Positioned(
                    top: 16,
                    left: 12,
                    child: CircleAvatar(
                      backgroundColor: Colors.white70,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    right: 12,
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white70,
                          child: IconButton(
                            icon: const Icon(Icons.share),
                            onPressed: () {
                              // TODO: Add share logic
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        CircleAvatar(
                          backgroundColor: Colors.white70,
                          child: IconButton(
                            icon: Icon(
                              isLoved ? Icons.favorite : Icons.favorite_border,
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

              // 🏨 Hotel name & location
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
                          color: Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          hotel.location,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 💰 Price & Book Now
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
                    const Text(
                      'Total includes taxes & fees',
                      style: TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                           context,
                           MaterialPageRoute(
                             builder: (context) => BookingPage(hotel: hotel),
                           ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 22, 98, 211),
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

              // 🏖️ Amenities section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 32,
                  runSpacing: 24,
                  children: hotel.amenities.map((amenity) {
                    return SizedBox(
                      width: 100,
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
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 24),

              // 📝 About section
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

              // ⭐ Ratings & Reviews
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
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '(${fakeReviewCount} reviews)',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      _buildReview(
                        name: 'Alicia R.',
                        image: 'https://i.pravatar.cc/150?img=3',
                        rating: 5,
                        text:
                            'Absolutely loved the private pool and spa! The staff were incredibly attentive and the beach access made our mornings magical.',
                      ),
                      const SizedBox(height: 20),
                      _buildReview(
                        name: 'Dev M.',
                        image: 'https://i.pravatar.cc/150?img=5',
                        rating: 4,
                        text:
                            'The yoga classes were a peaceful escape and the butler service was top-notch. Would definitely come back!',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ⚖️ Compare button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                       builder: (context) => BookingPage(hotel: hotel),
                        ),
                   );
                    // TODO: Compare logic or navigation
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReview({
    required String name,
    required String image,
    required int rating,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(radius: 24, backgroundImage: NetworkImage(image)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: List.generate(
                  rating,
                  (index) =>
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                ),
              ),
              const SizedBox(height: 4),
              Text(text, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }
}
