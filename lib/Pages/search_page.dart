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

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchHotels() async {
    try {
      final data = await supabase.from('hotels').select();

      if (data is List && data.isNotEmpty) {
        final hotelList = data.map<Hotel>((hotel) {
          return Hotel(
            hotelId: hotel['hotel_id'],
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
          );
        }).toList();

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
      debugPrint("❌ Error fetching hotels: $e");
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
      filteredHotels = query.isEmpty
          ? hotels
          : hotels.where((hotel) {
              return hotel.name.toLowerCase().contains(query) ||
                  hotel.location.toLowerCase().contains(query) ||
                  hotel.category.toLowerCase().contains(query);
            }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    const lightBlue = Color(0xFFE8F3FF);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Search Hotels',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
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
                        onPressed: () => searchController.clear(),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.blue[50],
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemBuilder: (context, index) {
                      final hotel = filteredHotels[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: lightBlue,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  hotel.imageUrl,
                                  width: 100,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                        width: 100,
                                        height: 80,
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.broken_image),
                                      ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      hotel.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      "${hotel.location} • ${hotel.category}",
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 16,
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
                                    const SizedBox(height: 6),
                                    Text(
                                      "${hotel.currency} ${hotel.pricePerNight.toStringAsFixed(2)} per night",
                                      style: const TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: ElevatedButton.icon(
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
                                        icon: const Icon(Icons.arrow_forward),
                                        label: const Text("View Details"),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue[800],
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              30,
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
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
