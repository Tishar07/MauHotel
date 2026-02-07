import 'package:flutter/material.dart';

import '../models/hotel_model.dart';
import '../models/review_model.dart';

import '../pages/booking_page.dart';
import '../pages/compare_hotels_page.dart';

import '../services/hoteldetails_backend.dart';

import '../components/factorybutton.dart';
import '../components/ratings_reviews_section.dart';

import '../theme/app_theme.dart';

import '../accessibility/accessibility_state.dart';

import 'add_review_page.dart';

// -------------------- HOTEL DETAILS PAGE --------------------
class HotelDetailsPage extends StatefulWidget {
  final Hotel hotel;

  const HotelDetailsPage({super.key, required this.hotel});

  @override
  State<HotelDetailsPage> createState() => _HotelDetailsPageState();
}

class _HotelDetailsPageState extends State<HotelDetailsPage> {
  final HotelDetailsService backend = HotelDetailsService();

  bool isLoved = false;
  bool isLoadingReviews = true;
  bool isLoadingHotels = true;

  List<Review> reviews = [];
  List<Hotel> allHotels = [];

  @override
  void initState() {
    super.initState();
    _loadReviews();
    _loadHotels();
  }

  Future<void> _loadReviews() async {
    final fetchedReviews = await backend.fetchReviews(widget.hotel.hotelId);
    if (!mounted) return;

    setState(() {
      reviews = fetchedReviews;
      isLoadingReviews = false;
    });
  }

  Future<void> _loadHotels() async {
    final fetchedHotels = await backend.fetchAllHotels();
    if (!mounted) return;

    setState(() {
      allHotels = fetchedHotels;
      isLoadingHotels = false;
    });
  }

  IconData getAmenityIcon(String amenity) {
    switch (amenity.toLowerCase()) {
      case 'wifi':
        return Icons.wifi;
      case 'pool':
        return Icons.pool;
      case 'spa':
        return Icons.spa;
      case 'restaurant':
        return Icons.restaurant;
      case 'gym':
        return Icons.fitness_center;
      case 'golf course':
        return Icons.golf_course;
      case 'snorkeling':
        return Icons.scuba_diving;
      case 'kids club':
        return Icons.child_care;
      case 'bar':
        return Icons.wine_bar;
      case 'tennis courts':
        return Icons.sports_tennis;
      case 'private beach':
        return Icons.beach_access_sharp;
      case 'room service':
        return Icons.room_service;
      case 'hiking trails':
        return Icons.hiking;
      case 'nature view':
        return Icons.forest;
      case 'eco tours':
        return Icons.eco;
      case 'boat excursions':
        return Icons.directions_boat;
      case 'water sports':
        return Icons.surfing;
      case 'all-inclusive':
        return Icons.all_inclusive;

      case 'beach access':
        return Icons.beach_access;

      case 'butler service':
        return Icons.person;

      case 'free wifi':
        return Icons.wifi;

      case 'infinity pool':
        return Icons.pool;

      case 'organic restaurant':
        return Icons.restaurant;

      case 'private pool':
        return Icons.pool;

      case 'rooftop bar':
        return Icons.wine_bar;

      case 'yoga classes':
        return Icons.self_improvement;

      case 'yoga pavilion':
        return Icons.self_improvement;

      default:
        return Icons.check_circle_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hotel = widget.hotel;

    return AnimatedBuilder(
      animation: AccessibilityState.rebuild,
      builder: (context, _) {
        final highContrast = AccessibilityState.contrast.value >= 2;

        return Scaffold(
          backgroundColor: highContrast ? Colors.black : Colors.white,

          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ================= HEADER IMAGE =================
                Stack(
                  children: [
                    Image.network(
                      hotel.imageUrl,
                      height: 300,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),

                    Container(
                      height: 300,
                      width: double.infinity,
                      color: Colors.black.withOpacity(0.25),
                    ),

                    Positioned(
                      top: 40,
                      left: 16,
                      child: CircleAvatar(
                        backgroundColor: AppTheme.primaryBlue,
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ),

                    Positioned(
                      top: 40,
                      right: 16,
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppTheme.primaryBlue,
                            child: IconButton(
                              icon: const Icon(
                                Icons.share,
                                color: Colors.white,
                              ),
                              onPressed: () {},
                            ),
                          ),

                          const SizedBox(width: 8),

                          CircleAvatar(
                            backgroundColor: Colors.white,
                            child: IconButton(
                              icon: Icon(
                                isLoved
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: Colors.red,
                              ),
                              onPressed: () =>
                                  setState(() => isLoved = !isLoved),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ================= HOTEL NAME =================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Center(
                    // <-- Wrap in Center
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment
                          .center, // <-- Ensure text inside is centered
                      children: [
                        Text(
                          hotel.name,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: highContrast ? Colors.white : Colors.black,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Row(
                          mainAxisSize:
                              MainAxisSize.min, // <-- makes row wrap tightly
                          mainAxisAlignment:
                              MainAxisAlignment.center, // <-- center the row
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 18,
                              color: Colors.red,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              hotel.location,
                              style: TextStyle(
                                color: highContrast
                                    ? Colors.white70
                                    : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // ----- PRICE -----
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AccessibilityState.t(
                                  'Rs ${hotel.pricePerNight.toStringAsFixed(2)} / night',
                                  'Rs ${hotel.pricePerNight.toStringAsFixed(2)} / nuit',
                                ),
                                style: TextStyle(
                                  color: highContrast
                                      ? Colors.white
                                      : AppTheme.primaryBlue,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                AccessibilityState.t(
                                  'Total includes taxes & fees',
                                  'Total inclut taxes et frais',
                                ),
                                style: const TextStyle(color: Colors.red),
                              ),
                            ],
                          ),

                          // ----- Push button to the right -----
                          const Spacer(),

                          // ----- BOOK BUTTON -----
                          SizedBox(
                            height: 50, // make button taller
                            child: PrimaryButton(
                              label: AccessibilityState.t(
                                'Book Now',
                                'Réserver',
                              ),
                              icon: Icons.book_online,
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BookingPage(hotel: hotel),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24), // spacing after section
                    ],
                  ),
                ),

                // ================= ABOUT =================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AccessibilityState.t(
                          'About this hotel',
                          'À propos de cet hôtel',
                        ),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: highContrast
                              ? Colors.white
                              : AppTheme.primaryBlue,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        AccessibilityState.translateDescription(
                          hotel.description,
                        ),
                        style: TextStyle(
                          fontSize: 16,
                          color: highContrast ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ================= AMENITIES =================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Wrap(
                    spacing: 32,
                    runSpacing: 24,
                    children: hotel.amenities.map((amenity) {
                      return Column(
                        children: [
                          Icon(
                            getAmenityIcon(amenity),
                            size: 28,
                            color: highContrast
                                ? Colors.white
                                : Colors.black, // <-- Add this line
                          ),
                          const SizedBox(height: 6),

                          SizedBox(
                            width: 80,
                            child: Text(
                              AccessibilityState.translateAmenity(amenity),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: highContrast
                                    ? Colors.white
                                    : Colors.black,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),

                // ================= REVIEWS =================
                Container(
                  color: highContrast
                      ? Colors.black
                      : Colors.white, // background
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 16, // aligns with other sections
                  ),
                  child: Align(
                    alignment: Alignment.topLeft, // ✅ align content to the left
                    child: RatingsReviewsSection(
                      isLoading: isLoadingReviews,
                      reviews: reviews,
                      showReviews: true,
                      showTitle: true,
                    ),
                  ),
                ),

                // ================= ADD REVIEW =================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AddReviewPage(hotelId: widget.hotel.hotelId),
                          ),
                        ).then((_) => _loadReviews());
                      },
                      icon: const Icon(
                        Icons.rate_review,
                        color: Colors.white, // ✅ icon white
                      ),
                      label: Text(
                        AccessibilityState.t(
                          'Add Review and Rating',
                          'Ajouter un avis et une note',
                        ),
                        style: const TextStyle(
                          color: Colors.white, // ✅ text white
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor:
                            Colors.white, // ✅ ensures icon/text stay white
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // ================= COMPARE =================
                Center(
                  child: PrimaryButton(
                    label: AccessibilityState.t(
                      'Compare Similar',
                      'Comparer hôtels similaires',
                    ),
                    icon: Icons.compare_arrows,
                    onPressed: isLoadingHotels
                        ? () {}
                        : () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  CompareHotelsPage(baseHotel: hotel),
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }
}
