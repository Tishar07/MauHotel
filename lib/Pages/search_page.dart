import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/hotel_model.dart';
import 'hotel_details_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final supabase = Supabase.instance.client;
  final TextEditingController searchController = TextEditingController();
  List<Hotel> hotels = [];
  List<Hotel> filteredHotels = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchHotels();
    searchController.addListener(() => filterHotels());
  }

  Future<void> fetchHotels() async {
    try {
      final data = await supabase.from('hotels').select();

      if (data != null && data is List) {
        final hotelList = data
            .map<Hotel>(
              (hotel) => Hotel(
                id: hotel['id'],
                name: hotel['name'],
                imageUrl: hotel['image_url'],
                description: hotel['description'],
                rating: hotel['rating']?.toDouble() ?? 0.0,
                reviews: hotel['reviews'] ?? 0,
                discount: hotel['discount'] ?? 0,
                pricePerNight: hotel['price']?.toDouble() ?? 0.0,
                currency: 'Rs',
              ),
            )
            .toList();

        setState(() {
          hotels = hotelList;
          filteredHotels = hotelList;
          isLoading = false;
        });
      }
    } catch (e) {
      print("❌ Error fetching hotels: $e");
      setState(() {
        hotels = [];
        filteredHotels = [];
        isLoading = false;
      });
    }
  }

  void filterHotels() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredHotels = hotels.where((hotel) {
        return hotel.name.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Hotels')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search by hotel name...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredHotels.isEmpty
                ? const Center(child: Text("No hotels found."))
                : ListView.builder(
                    itemCount: filteredHotels.length,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemBuilder: (_, index) {
                      final hotel = filteredHotels[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                              child: Image.network(
                                hotel.imageUrl,
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  height: 180,
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: Icon(Icons.broken_image),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    hotel.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Rating: ${hotel.rating}/5 (${hotel.reviews} reviews)",
                                  ),
                                  Text("Discount: ${hotel.discount}% OFF"),
                                  Text(
                                    "Price: ${hotel.currency} ${hotel.pricePerNight.toStringAsFixed(2)} per night",
                                  ),
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                HotelDetailsPage(hotel: hotel),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue[900],
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                      ),
                                      child: const Text("View"),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
