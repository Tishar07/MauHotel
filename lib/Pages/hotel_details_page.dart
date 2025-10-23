import 'package:flutter/material.dart';
import '../models/hotel_model.dart';

class HotelDetailsPage extends StatelessWidget {
  final Hotel hotel;

  const HotelDetailsPage({super.key, required this.hotel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(hotel.name)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hotel Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  hotel.imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(
                        Icons.broken_image,
                        size: 48,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Hotel Name
              Text(
                hotel.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Price
              Text(
                '${hotel.pricePerNight.toStringAsFixed(2)} ${hotel.currency} per night',
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),

              // Location, Type, Category
              Row(
                children: [
                  const Icon(Icons.location_on, size: 18),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${hotel.location} • ${hotel.type} • ${hotel.category}',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Rating
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(
                    '${hotel.ratingAvg}/5',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Available Rooms
              Text(
                'Available Rooms: ${hotel.roomsAvailable}',
                style: TextStyle(color: Colors.grey[700]),
              ),
              const SizedBox(height: 8),

              // Available Dates
              Text(
                'Available From: ${hotel.availableFrom}  To: ${hotel.availableTo}',
                style: TextStyle(color: Colors.grey[700]),
              ),
              const SizedBox(height: 16),

              // Amenities
              if (hotel.amenities.isNotEmpty) ...[
                const Text(
                  'Amenities',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: hotel.amenities
                      .map(
                        (amenity) => Chip(
                          label: Text(amenity),
                          backgroundColor: Colors.blue[100],
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 16),
              ],

              // Description
              const Text(
                'Description',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(hotel.description, style: const TextStyle(fontSize: 16)),

              const SizedBox(height: 24),

              // Book Now Button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Add booking logic
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[900],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Book Now',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
