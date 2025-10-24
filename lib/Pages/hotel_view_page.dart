import 'package:flutter/material.dart';
import '../services/supabase_service.dart'; //
import '../models/hotel_model.dart'; // your hotel model
import 'booking_page.dart';


class HotelViewPage extends StatefulWidget {
  final String hotelId;

  const HotelViewPage({Key? key, required this.hotelId}) : super(key: key);

  @override
  State<HotelViewPage> createState() => _HotelViewPageState();
}

class _HotelViewPageState extends State<HotelViewPage> {
  late Future<Hotel> hotelFuture;

  @override
  void initState() {
    super.initState();
    hotelFuture = SupabaseService().getHotelById(
      widget.hotelId,
    ); // adjust method name
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
          return buildHotelUI(hotel);
        },
      ),
    );
  }

  Widget buildHotelUI(Hotel hotel) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(hotel.imageUrl, fit: BoxFit.cover),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(hotel.name, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber),
                    Text('${hotel.ratingAvg}'),
                  ],
                ),
                const SizedBox(height: 16),
                Text(hotel.description),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  children: hotel.amenities
                      .map((a) => Chip(label: Text(a)))
                      .toList(),
                ),
                const SizedBox(height: 16),
                Text(
                  'Rs ${hotel.pricePerNight}',
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                       builder: (context) => BookingPage(hotel: hotel),
                        ),
                   );
                  },
                  child: const Text('Book Now'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
