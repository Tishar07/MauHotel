import 'package:flutter/material.dart';
import '../models/hotel_model.dart';

class HotelDetailsPage extends StatelessWidget {
  final Hotel hotel; // <-- add this

  const HotelDetailsPage({super.key, required this.hotel}); // <-- named parameter

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(hotel.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              hotel.imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 16),
            Text(
              hotel.name,
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '${hotel.pricePerNight.toStringAsFixed(2)} ${hotel.currency}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(hotel.description),
          ],
        ),
      ),
    );
  }
}
