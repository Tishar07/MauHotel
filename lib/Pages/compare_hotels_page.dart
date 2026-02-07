import 'package:flutter/material.dart';
import '../models/hotel_model.dart';
import '../models/review_model.dart';
import '../services/comparehotels_backend.dart';
import '../theme/app_theme.dart';
import '../accessibility/accessibility_state.dart'; // for translations
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
    return AnimatedBuilder(
      animation: AccessibilityState.rebuild,
      builder: (context, _) {
        final highContrast = AccessibilityState.contrast.value >= 2;

        return Scaffold(
          backgroundColor: highContrast ? Colors.black : Colors.white,
          appBar: AppBar(
            title: Text(
              AccessibilityState.t('Compare Similar', 'Comparer similaires'),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: highContrast ? Colors.white : AppTheme.primaryBlue,
              ),
            ),
            centerTitle: true,
            backgroundColor: highContrast ? Colors.black : Colors.white,
            iconTheme: IconThemeData(
              color: highContrast ? Colors.white : AppTheme.primaryBlue,
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryBlue,
                    ),
                  )
                : _hotelsToCompare.isEmpty
                ? Center(
                    child: Text(
                      AccessibilityState.t(
                        'No similar hotels found',
                        'Aucun hôtel similaire trouvé',
                      ),
                      style: TextStyle(
                        color: highContrast ? Colors.white : Colors.black,
                      ),
                    ),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _hotelsToCompare.length,
                    itemBuilder: (context, index) {
                      final hotel = _hotelsToCompare[index];
                      return _CompareHotelCard(
                        hotel: hotel,
                        reviews: _hotelReviews[hotel.hotelId] ?? [],
                        isLoadingReviews:
                            _reviewsLoading[hotel.hotelId] ?? true,
                        highContrast: highContrast,
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
      },
    );
  }
}

class _CompareHotelCard extends StatelessWidget {
  final Hotel hotel;
  final List<Review> reviews;
  final bool isLoadingReviews;
  final bool highContrast;
  final VoidCallback onTap;

  const _CompareHotelCard({
    required this.hotel,
    required this.reviews,
    required this.isLoadingReviews,
    required this.highContrast,
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
          color: highContrast ? Colors.black : AppTheme.lightBlue,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: highContrast ? Colors.white : Colors.transparent,
            width: highContrast ? 2 : 0,
          ),
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
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: highContrast ? Colors.white : Colors.black,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            ...hotel.amenities.take(3).map(_amenityRow).toList(),
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
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: highContrast ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  AccessibilityState.t(
                    '(${reviews.length} reviews)',
                    '(${reviews.length} avis)',
                  ),
                  style: TextStyle(
                    color: highContrast ? Colors.white70 : Colors.grey,
                    fontSize: 13,
                  ),
                ),
              ],
            ),

            const Spacer(), // Push price to bottom
            // ================= PRICE SECTION =================
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${hotel.currency} ${hotel.pricePerNight.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: highContrast ? Colors.white : AppTheme.primaryBlue,
                    ),
                  ),
                  Text(
                    AccessibilityState.t('per night', 'par nuit'),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: highContrast ? Colors.white : AppTheme.primaryBlue,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12), // spacing from bottom if needed
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
    } else if (lower.contains('wifi')) {
      icon = Icons.wifi;
    } else if (lower.contains('spa')) {
      icon = Icons.spa;
    } else if (lower.contains('bar')) {
      icon = Icons.wine_bar;
    } else if (lower.contains('gym')) {
      icon = Icons.fitness_center;
    } else if (lower.contains('tennis')) {
      icon = Icons.sports_tennis;
    } else if (lower.contains('yoga')) {
      icon = Icons.self_improvement;
    } else if (lower.contains('snorkeling')) {
      icon = Icons.scuba_diving;
    } else if (lower.contains('hiking')) {
      icon = Icons.hiking;
    } else if (lower.contains('nature')) {
      icon = Icons.forest;
    } else if (lower.contains('eco')) {
      icon = Icons.eco;
    } else if (lower.contains('boat')) {
      icon = Icons.directions_boat;
    } else if (lower.contains('all-inclusive')) {
      icon = Icons.all_inclusive;
    } else if (lower.contains('butler')) {
      icon = Icons.person;
    } else {
      icon = Icons.check_circle_outline;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: highContrast ? Colors.white : Colors.black,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              AccessibilityState.translateAmenity(amenity),
              style: TextStyle(
                fontSize: 13,
                color: highContrast ? Colors.white : Colors.black,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
