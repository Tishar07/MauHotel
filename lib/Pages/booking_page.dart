import 'package:flutter/material.dart';
import '../models/hotel_model.dart';
import 'Pay_Page.dart';


class BookingPage extends StatefulWidget {
  final Hotel hotel;

  const BookingPage({Key? key, required this.hotel}) : super(key: key);

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  int rooms = 1;
  int nights = 1;
  String bedType = 'Single';

  double get totalPrice => widget.hotel.pricePerNight * rooms * nights;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book Your Stay')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.hotel.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: const Color.fromARGB(255, 13, 32, 248))),
            const SizedBox(height: 16),

            // Rooms
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Rooms'),
                DropdownButton<int>(
                  value: rooms,
                  items: List.generate(5, (i) => DropdownMenuItem(value: i + 1, child: Text('${i + 1}'))),
                  onChanged: (val) => setState(() => rooms = val!),
                ),
              ],
            ),

            // Nights
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Nights'),
                DropdownButton<int>(
                  value: nights,
                  items: List.generate(14, (i) => DropdownMenuItem(value: i + 1, child: Text('${i + 1}'))),
                  onChanged: (val) => setState(() => nights = val!),
                ),
              ],
            ),

            // Bed Type
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Bed Type'),
                DropdownButton<String>(
                  value: bedType,
                  items: const [
                    DropdownMenuItem(value: 'Single', child: Text('Single')),
                    DropdownMenuItem(value: 'Double', child: Text('Double')),
                    DropdownMenuItem(value: 'Queen', child: Text('Queen')),
                    DropdownMenuItem(value: 'King', child: Text('King')),
                  ],
                  onChanged: (val) => setState(() => bedType = val!),
                ),
              ],
            ),

            const SizedBox(height: 20),
            Text('Total Price: Rs ${totalPrice.toStringAsFixed(0)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),

            const Spacer(),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentPage(
                      hotel: widget.hotel,
                      rooms: rooms,
                      nights: nights,
                      bedType: bedType,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.payment),
              label: const Text('Pay Now'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(198, 240, 9, 9),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 