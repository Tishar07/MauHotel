import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome to MauHotel, Pushkaar!')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Hotels...', style: TextStyle(fontSize: 20)),
          const SizedBox(height: 10),
          _hotelCard(
            context,
            name: 'Veranda Beach Hotel',
            rating: 3.9,
            reviews: 8,
            location: 'Northern Mauritius overlooking the ocean',
            discount: '20% OFF',
            price: 'Rs. 8,455',
          ),
          _hotelCard(
            context,
            name: 'Sea Resorts Hotel',
            rating: 4.2,
            reviews: 120,
            location: 'Landscape gardens by the ocean',
            discount: '10% OFF',
            price: 'Rs. 9,455',
          ),
          _hotelCard(
            context,
            name: 'Sofitel Mauritius L\'Imperial',
            rating: 4.6,
            reviews: 150,
            location: 'Northern Mauritius beachfront',
            discount: '10% OFF',
            price: 'Rs. 5,455',
          ),
        ],
      ),
      bottomNavigationBar: _bottomNav(context),
    );
  }

  Widget _hotelCard(
    BuildContext context, {
    required String name,
    required double rating,
    required int reviews,
    required String location,
    required String discount,
    required String price,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(name),
        subtitle: Text('$location\n$discount • $price per night'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text('$rating★'), Text('($reviews reviews)')],
        ),
        onTap: () => Navigator.pushNamed(context, '/hotel'),
      ),
    );
  }

  Widget _bottomNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0,
      onTap: (index) {
        switch (index) {
          case 1:
            Navigator.pushNamed(context, '/trip');
            break;
          case 2:
            Navigator.pushNamed(context, '/search');
            break;
          case 3:
            Navigator.pushNamed(context, '/account');
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.timeline), label: 'Trip Plan'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'My Profile'),
      ],
    );
  }
}
