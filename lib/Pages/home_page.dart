import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Fetch user's name from Supabase
    final String userName = 'Naga Pushkaar'; // Replace with Supabase data

    // TODO: Replace this static list with data fetched from SerpAPI or Supabase
    final List<Map<String, dynamic>> hotels = [
      {
        'name': 'Veranda Beach Hotel',
        'rating': 3.9,
        'reviews': 200,
        'description': 'Set in Northern Mauritius overlooking the ...',
        'offer': '25% OFF',
        'price': 'Rs 8,455 per night',
        'imageUrl': 'https://example.com/image1.jpg',
      },
      {
        'name': 'Sea Resorts Hotel',
        'rating': 4.7,
        'reviews': 1200,
        'description': 'Set in landscaped gardens overlooking the ...',
        'offer': '15% OFF',
        'price': 'Rs 4,500 per night',
        'imageUrl': 'https://example.com/image2.jpg',
      },
      {
        'name': 'Sofitel Mauritius L’Imperial',
        'rating': 4.0,
        'reviews': 1500,
        'description': 'Set in Northern Mauritius overlooking the ...',
        'offer': '10% OFF',
        'price': 'Rs 5,455 per night',
        'imageUrl': 'https://example.com/image3.jpg',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,

      // ✅ Page Content
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting
            Text(
              'Welcome to MauHotel,\n$userName!',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Search Bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Hotels...',
                prefixIcon: const Icon(Icons.search),
                fillColor: Colors.blue.shade50,
                filled: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Filter and Sort Buttons
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implement filter functionality
                  },
                  icon: const Icon(Icons.filter_list),
                  label: const Text("Filter By"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade800,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implement sort functionality
                  },
                  icon: const Icon(Icons.sort),
                  label: const Text("Sort By"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade800,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ✅ Hotel List
            Expanded(
              child: ListView.builder(
                itemCount: hotels.length,
                itemBuilder: (context, index) {
                  final hotel = hotels[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    color: Colors.blue.shade50,
                    margin: const EdgeInsets.only(bottom: 20),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Hotel Image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              hotel['imageUrl'],
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 100,
                                  width: 100,
                                  color: Colors.grey,
                                  child: const Icon(Icons.image),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Hotel Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  hotel['name'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.star,
                                        color: Colors.orange, size: 16),
                                    Text(
                                      '${hotel['rating']}/5',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Reviews (${hotel['reviews']})',
                                      style: const TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  hotel['description'],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Text(
                                      hotel['offer'],
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      hotel['price'],
                                      style: TextStyle(
                                        color: Colors.blue.shade800,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // View Button
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              onPressed: () {
                                // TODO: Navigate to hotel details
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade800,
                                shape: const CircleBorder(),
                                padding: const EdgeInsets.all(12),
                              ),
                              child: const Icon(Icons.arrow_forward),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

    );
  }
}
