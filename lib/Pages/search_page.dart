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
    searchController.addListener(filterHotels);
  }

  Future<void> fetchHotels() async {
    try {
      final data = await supabase.from('hotels').select();

      if (data is List && data.isNotEmpty) {
        final hotelList = data
            .map<Hotel>(
              (hotel) => Hotel(
                hotelId: hotel['hotel_id'], // Required field
                name: hotel['name'] ?? 'Unnamed Hotel',
                location: hotel['location'] ?? 'Unknown Location',
                type: hotel['type'] ?? 'General',
                description: hotel['description'] ?? 'No description available',
                pricePerNight: (hotel['price_per_night'] ?? 0).toDouble(),
                currency: hotel['currency'] ?? 'Rs',
                category: hotel['category'] ?? 'General',
                imageUrl: hotel['image_url'] ?? '',
                amenities:
                    (hotel['amenities'] as List?)
                        ?.map((e) => e.toString())
                        .toList() ??
                    [],
                availableFrom: hotel['available_from'] ?? '',
                availableTo: hotel['available_to'] ?? '',
                roomsAvailable: hotel['rooms_available'] ?? 0,
                ratingAvg: (hotel['rating_avg'] ?? 0).toDouble(),
              ),
            )
            .toList();

        setState(() {
          hotels = hotelList;
          filteredHotels = hotelList;
          isLoading = false;
        });
      } else {
        setState(() {
          hotels = [];
          filteredHotels = [];
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load hotels. Please try again.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void filterHotels() {
    final query = searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        filteredHotels = hotels;
      } else {
        filteredHotels = hotels.where((hotel) {
          return hotel.name.toLowerCase().contains(query) ||
              hotel.location.toLowerCase().contains(query) ||
              hotel.category.toLowerCase().contains(query);
        }).toList();
      }
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
      appBar: AppBar(
        title: const Text('Search Hotels'),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search by hotel name, location, or category...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredHotels.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          searchController.text.isEmpty
                              ? "No hotels available."
                              : "No hotels found matching '${searchController.text}'",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredHotels.length,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemBuilder: (context, index) {
                      final hotel = filteredHotels[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      height: 180,
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
                                    "${hotel.location} • ${hotel.type} • ${hotel.category}",
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        "${hotel.ratingAvg}/5",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Available rooms: ${hotel.roomsAvailable}",
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "${hotel.currency} ${hotel.pricePerNight.toStringAsFixed(2)}",
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  HotelDetailsPage(
                                                    hotel: hotel,
                                                  ),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue[900],
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 12,
                                          ),
                                        ),
                                        child: const Text(
                                          "View Details",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
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
