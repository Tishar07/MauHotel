import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/hotel_model.dart';
import 'hotel_details_page.dart';

class CompareHotelsPage extends StatefulWidget {
  final Hotel baseHotel;

  const CompareHotelsPage({super.key, required this.baseHotel});

  @override
  State<CompareHotelsPage> createState() => _CompareHotelsPageState();
}

class _CompareHotelsPageState extends State<CompareHotelsPage> {
  final supabase = Supabase.instance.client;

  bool _isLoading = true;
  List<Hotel> _allHotels = [];
  List<Hotel> _hotelsToCompare = [];

  @override
  void initState() {
    super.initState();
    _fetchHotels();
  }

  Future<void> _fetchHotels() async {
    setState(() => _isLoading = true);

    try {
      final data = await supabase.from('hotels').select(); // Fetch all hotels
      final hotels = (data as List).map((e) => Hotel.fromJson(e)).toList();
      _allHotels = hotels;

      // Get similar hotels using the scoring function
      final similarHotels = _getSimilarHotels(widget.baseHotel, _allHotels);

      // Always show the selected hotel first
      setState(() {
        _hotelsToCompare = [widget.baseHotel, ...similarHotels];
      });

      print(
        'Hotels to compare: ${_hotelsToCompare.map((h) => h.name).toList()}',
      );
    } catch (e, st) {
      debugPrint('Error fetching hotels: $e\n$st');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to fetch hotels')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Returns hotels ranked by similarity amenities price
  List<Hotel> _getSimilarHotels(Hotel base, List<Hotel> hotels) {
    final baseAmenities = base.amenities.map((a) => a.toLowerCase()).toSet();
    final basePrice = base.pricePerNight;

    const double priceRange = 5000; // Price difference range for similarity
    const int maxResults = 3; // Max similar hotels to display

    final scoredHotels = <_ScoredHotel>[];

    for (final hotel in hotels) {
      if (hotel.hotelId == base.hotelId) continue;

      // Compare amenities
      final hotelAmenities = hotel.amenities
          .map((a) => a.toLowerCase())
          .toSet();
      final commonAmenities = baseAmenities.intersection(hotelAmenities).length;
      final amenityScore = baseAmenities.isEmpty
          ? 0
          : commonAmenities / (baseAmenities.length + 1);

      // Compare price similarity
      final priceDifference = (hotel.pricePerNight - basePrice).abs();
      final priceScore = priceDifference > priceRange
          ? 0
          : 1 - (priceDifference / priceRange);

      // Total weighted
      final totalScore = (amenityScore * 0.6) + (priceScore * 0.4);

      scoredHotels.add(_ScoredHotel(hotel, totalScore));

      // print score calculation for each hotel
      print(
        'Hotel: ${hotel.name}, Amenities Score: $amenityScore, Price Score: $priceScore, Total Score: $totalScore',
      );
    }

    // Sort hotels by score descending
    scoredHotels.sort((a, b) => b.score.compareTo(a.score));

    // Take top N results
    final similarHotels = scoredHotels
        .take(maxResults)
        .map((e) => e.hotel)
        .toList();

    // Debug: print similar hotels
    print('Similar hotels: ${similarHotels.map((h) => h.name).toList()}');

    return similarHotels;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Compare Similar',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 0, 94, 172),
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              ) // Loading indicator
            : _hotelsToCompare.isEmpty
            ? const Center(child: Text('No similar hotels found')) // No results
            : ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _hotelsToCompare.length,
                itemBuilder: (context, index) {
                  final hotel = _hotelsToCompare[index];
                  return _CompareHotelCard(
                    hotel: hotel,
                    onTap: () {
                      // Navigate to hotel details on tap
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HotelDetailsPage(hotel: hotel),
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}

/// Individual hotel card for comparison
class _CompareHotelCard extends StatelessWidget {
  final Hotel hotel;
  final VoidCallback onTap;

  const _CompareHotelCard({required this.hotel, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Navigate to hotel details
      child: Container(
        width: 260,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFEAF4FF),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hotel image
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.network(
                hotel.imageUrl,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 12),
            // Hotel name
            Text(
              hotel.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            // Top 3 amenities
            ...hotel.amenities.take(3).map(_amenityRow),
            const Spacer(),
            // Rating row
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 20),
                const SizedBox(width: 4),
                Text(
                  '${hotel.ratingAvg.toStringAsFixed(1)}/5',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Price
            Text(
              '${hotel.currency} ${hotel.pricePerNight.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 0, 94, 172),
              ),
            ),
            const Text('per night', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  /// Builds a row for a single amenity with icon
  Widget _amenityRow(String amenity) {
    IconData icon = Icons.check_circle_outline;
    final lower = amenity.toLowerCase();

    if (lower.contains('pool')) {
      icon = Icons.pool;
    } else if (lower.contains('beach')) {
      icon = Icons.beach_access;
    } else if (lower.contains('breakfast') || lower.contains('restaurant')) {
      icon = Icons.restaurant;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.black87),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              amenity,
              style: const TextStyle(fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoredHotel {
  final Hotel hotel;
  final double score;

  _ScoredHotel(this.hotel, this.score);
}
