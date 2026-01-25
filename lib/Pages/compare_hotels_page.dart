import 'package:flutter/material.dart';
import '../models/hotel_model.dart';
import '../models/review_model.dart';
import '../services/comparehotels_backend.dart';
import '../theme/app_theme.dart';
import 'hotel_details_page.dart';

class CompareHotelsPage extends StatefulWidget {
  final Hotel baseHotel;
  const CompareHotelsPage({super.key, required this.baseHotel});

  @override
  State<CompareHotelsPage> createState() => _CompareHotelsPageState();
}

class _CompareHotelsPageState extends State<CompareHotelsPage> {
  final CompareHotelsService _service = CompareHotelsService();

  bool _isLoading = true;
  List<Hotel> _hotelsToCompare = [];

  // Store reviews per hotel
  Map<int, List<Review>> _hotelReviews = {};
  Map<int, bool> _reviewsLoading = {};

  @override
  void initState() {
    super.initState();
    _loadHotels();
  }

  Future<void> _loadHotels() async {
    setState(() => _isLoading = true);

    final allHotels = await _service.fetchAllHotels();
    final similarHotels = _service.getSimilarHotels(
      widget.baseHotel,
      allHotels,
    );

    final hotels = [widget.baseHotel, ...similarHotels];

    // Initialize reviews loading state
    for (var hotel in hotels) {
      _reviewsLoading[hotel.hotelId] = true;
      _hotelReviews[hotel.hotelId] = [];
      _fetchReviews(hotel.hotelId);
    }

    setState(() {
      _hotelsToCompare = hotels;
      _isLoading = false;
    });
  }

  Future<void> _fetchReviews(int hotelId) async {
    final reviews = await _service.fetchReviews(hotelId);
    if (!mounted) return;

    setState(() {
      _hotelReviews[hotelId] = reviews;
      _reviewsLoading[hotelId] = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Compare Similar',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryBlue,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryBlue),
              )
            : _hotelsToCompare.isEmpty
            ? const Center(child: Text('No similar hotels found'))
            : ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _hotelsToCompare.length,
                itemBuilder: (context, index) {
                  final hotel = _hotelsToCompare[index];
                  return _CompareHotelCard(
                    hotel: hotel,
                    reviews: _hotelReviews[hotel.hotelId] ?? [],
                    isLoadingReviews: _reviewsLoading[hotel.hotelId] ?? true,
                    onTap: () {
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

class _CompareHotelCard extends StatelessWidget {
  final Hotel hotel;
  final List<Review> reviews;
  final bool isLoadingReviews;
  final VoidCallback onTap;

  const _CompareHotelCard({
    required this.hotel,
    required this.reviews,
    required this.isLoadingReviews,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 260,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.lightBlue,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            Text(
              hotel.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            ...hotel.amenities.take(3).map(_amenityRow),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 20),
                const SizedBox(width: 4),
                Text(
                  reviews.isEmpty
                      ? hotel.ratingAvg.toStringAsFixed(1)
                      : (reviews.fold(0.0, (sum, r) => sum + r.rating) /
                                reviews.length)
                            .toStringAsFixed(1),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 6),
                Text(
                  '(${reviews.length} reviews)',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
            const Spacer(),
            const SizedBox(height: 10),
            Text(
              '${hotel.currency} ${hotel.pricePerNight.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlue,
              ),
            ),
            const Text(
              'per night',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }

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
          Icon(icon, size: 18, color: Colors.black),
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
