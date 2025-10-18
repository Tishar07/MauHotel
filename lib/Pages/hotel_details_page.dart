import 'package:flutter/material.dart';

class HotelDetailsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Top Image
              Stack(
                children: [
                  Image.asset('assets/constance_prince_maurice.jpg'),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.arrow_back),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 50,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.share),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.favorite_border),
                    ),
                  ),
                ],
              ),

              // Hotel name and price
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Constance Prince Maurice',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Text(
                      'Rs 10,000 nightly',
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Total includes taxes and fees',
                      style: TextStyle(color: Colors.red),
                    ),
                    Spacer(),
                    ElevatedButton(
                      onPressed: () {},
                      child: Text("Book Now"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                    )
                  ],
                ),
              ),

              Divider(),

              // About this Hotel
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'About this Hotel',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Wrap(
                  spacing: 20,
                  runSpacing: 12,
                  children: [
                    IconLabel(icon: Icons.beach_access, label: "On beach"),
                    IconLabel(icon: Icons.pool, label: "2 outdoor pools"),
                    IconLabel(icon: Icons.hot_tub, label: "Hot tub on site"),
                    IconLabel(icon: Icons.restaurant, label: "Vegetarian breakfast"),
                    IconLabel(icon: Icons.local_parking, label: "Self-parking included"),
                    IconLabel(icon: Icons.wifi, label: "Wi-Fi"),
                    IconLabel(icon: Icons.airport_shuttle, label: "Airport shuttle"),
                  ],
                ),
              ),

              Divider(),

              // Ratings and Reviews
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Text("⭐️⭐️⭐️⭐️", style: TextStyle(fontSize: 18)),
                    SizedBox(width: 10),
                    Text("4.0 Great", style: TextStyle(fontSize: 18)),
                  ],
                ),
              ),

              ReviewItem(
                name: 'Mikal',
                rating: '3.5/5',
                review:
                    'Beautiful and peaceful resort. The overwater suites and floating restaurant are stunning.',
              ),
              ReviewItem(
                name: 'Joe',
                rating: '4.5/5',
                review:
                    'Fantastic family holiday. Spacious villas, great kids’ club, and delicious food.',
              ),

              Center(
                child: ElevatedButton(
                  onPressed: () {},
                  child: Text("See All 150 Reviews"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                ),
              ),

              Divider(),

              // Compare Similar Hotels
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Compare Similar',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    SimilarHotelCard(
                      name: 'Constance Prince Maurice',
                      imagePath: 'assets/constance_prince_maurice.jpg',
                      price: 'Rs 10,000 per night',
                      rating: '4.0/5',
                      reviews: '150',
                    ),
                    SizedBox(width: 16),
                    SimilarHotelCard(
                      name: 'Veranda Beach Hotel',
                      imagePath: 'assets/veranda.jpg',
                      price: 'Rs 8,455 per night',
                      rating: '3.9/5',
                      reviews: '200',
                      discount: '25% OFF',
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// Reusable widgets
class IconLabel extends StatelessWidget {
  final IconData icon;
  final String label;

  IconLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: Colors.blue),
        SizedBox(width: 5),
        Text(label),
      ],
    );
  }
}

class ReviewItem extends StatelessWidget {
  final String name;
  final String rating;
  final String review;

  ReviewItem({required this.name, required this.rating, required this.review});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(child: Text(name[0])),
      title: Text('$rating'),
      subtitle: Text(review),
      trailing: Text(name),
    );
  }
}

class SimilarHotelCard extends StatelessWidget {
  final String imagePath;
  final String name;
  final String price;
  final String rating;
  final String reviews;
  final String? discount;

  SimilarHotelCard({
    required this.imagePath,
    required this.name,
    required this.price,
    required this.rating,
    required this.reviews,
    this.discount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.asset(imagePath, height: 100, width: double.infinity, fit: BoxFit.cover),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text('$rating  Reviews ($reviews)'),
            ),
            if (discount != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(discount!, style: TextStyle(color: Colors.red)),
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(price, style: TextStyle(color: Colors.blue)),
            ),
          ],
        ),
      ),
    );
  }
}
