import 'package:flutter/material.dart';
import '../models/hotel_model.dart';

class PaymentPage extends StatelessWidget {
  final Hotel hotel;
  final int rooms;
  final int nights;
  final String bedType;

  const PaymentPage({
    Key? key,
    required this.hotel,
    required this.rooms,
    required this.nights,
    required this.bedType,
  }) : super(key: key);

  double get totalPrice => hotel.pricePerNight * rooms * nights;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Payment')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                 color: const Color.fromARGB(255, 137, 190, 244),
                 borderRadius: BorderRadius.circular(8),
                 border: Border.all(color: const Color.fromARGB(255, 143, 189, 233)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Price Details', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 30, 5, 247))),
                  const SizedBox(height: 12),
                  Text('Hotel: ${hotel.name}', style: const TextStyle(fontSize: 16)),
                  Text('Duration: $nights Night${nights > 1 ? 's' : ''} × $rooms Room${rooms > 1 ? 's' : ''}', style: const TextStyle(fontSize: 16)),
                  Text('Dates: 20 Oct – 15 Dec 2025', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('Total Cost: Rs ${totalPrice.toStringAsFixed(0)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            Text('Who\'s Checking In?', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 16, 28, 247))),
            const SizedBox(height: 12),
            TextField(decoration: InputDecoration(labelText: 'First Name', labelStyle: const TextStyle(fontSize: 16), border: const OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(decoration: InputDecoration(labelText: 'Last Name', labelStyle: const TextStyle(fontSize: 16), border: const OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(decoration: InputDecoration(labelText: 'Email', labelStyle: const TextStyle(fontSize: 16), border: const OutlineInputBorder()), keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 12),
            TextField(decoration: InputDecoration(labelText: 'Phone Number', labelStyle: const TextStyle(fontSize: 16), border: const OutlineInputBorder()), keyboardType: TextInputType.phone),

            const SizedBox(height: 24),
            Text('Payment Details', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color:Color.fromARGB(255, 7, 39, 244))),
            const SizedBox(height: 12),
            TextField(decoration: InputDecoration(labelText: 'Name on Card', labelStyle: const TextStyle(fontSize: 16), border: const OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(decoration: InputDecoration(labelText: 'Card Number', labelStyle: const TextStyle(fontSize: 16), border: const OutlineInputBorder()), keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            TextField(decoration: InputDecoration(labelText: 'Expiry Date (MM/YY)', labelStyle: const TextStyle(fontSize: 16), border: const OutlineInputBorder()), keyboardType: TextInputType.datetime),
            const SizedBox(height: 12),
            TextField(decoration: InputDecoration(labelText: 'Security Code (CVV)', labelStyle: const TextStyle(fontSize: 16), border: const OutlineInputBorder()), obscureText: true, keyboardType: TextInputType.number),

            const SizedBox(height: 24),
            Text('Total: Rs ${totalPrice.toStringAsFixed(0)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Payment successful!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text('Pay Now'),
            ),
          ],
        ),
      ),
    );
  }
}
