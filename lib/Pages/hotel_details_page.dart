import 'package:flutter/material.dart'; // Core Flutter widgets

import '../models/hotel_model.dart'; // Hotel class model
import '../models/review_model.dart'; // Review class model

import '../pages/booking_page.dart'; // BookingPage for "Book Now" button
import '../pages/compare_hotels_page.dart'; // CompareHotelsPage for comparing hotels

import '../services/hoteldetails_backend.dart'; // Backend service to fetch hotels & reviews

import '../components/factorybutton.dart'; // PrimaryButton reusable widget
import '../components/ratings_reviews_section.dart'; // Reusable widget to display reviews

import '../theme/app_theme.dart'; // Custom theme colors & styling

import 'add_review_page.dart';

// -------------------- HOTEL DETAILS PAGE --------------------
/// Main page showing detailed info for a selected hotel
class HotelDetailsPage extends StatefulWidget {
  final Hotel hotel; // Hotel object passed from previous page

  const HotelDetailsPage({super.key, required this.hotel});

  @override
  State<HotelDetailsPage> createState() => _HotelDetailsPageState();
}

class _HotelDetailsPageState extends State<HotelDetailsPage> {
  final HotelDetailsService backend = HotelDetailsService();
  // Backend service to fetch reviews and all hotels

  bool isLoved = false; // Favorite toggle
  bool isLoadingReviews = true; // Loading state for reviews section
  bool isLoadingHotels = true; // Loading state for "Compare Similar" button

  List<Review> reviews = []; // Stores reviews fetched from backend
  List<Hotel> allHotels = []; // Stores all hotels for comparison

  @override
  void initState() {
    super.initState();
    _loadReviews(); // Fetch reviews for this hotel
    _loadHotels(); // Fetch all hotels for comparison
  }

  // -------------------- LOAD REVIEWS --------------------
  /// Fetch reviews from backend for the current hotel
  Future<void> _loadReviews() async {
    final fetchedReviews = await backend.fetchReviews(widget.hotel.hotelId);

    if (!mounted) return; // Prevent setState if widget is disposed

    setState(() {
      reviews = fetchedReviews; // Store reviews
      isLoadingReviews = false; // Stop loading indicator
    });
  }

  // -------------------- LOAD ALL HOTELS --------------------
  /// Fetch all hotels for "Compare Similar" feature
  Future<void> _loadHotels() async {
    final fetchedHotels = await backend.fetchAllHotels();

    if (!mounted) return;

    setState(() {
      allHotels = fetchedHotels; // Store all hotels
      isLoadingHotels = false; // Enable "Compare Similar" button
    });
  }

  // -------------------- AMENITY ICON MAPPER --------------------
  /// Returns an appropriate icon for each amenity
  IconData getAmenityIcon(String amenity) {
    switch (amenity.toLowerCase()) {
      case 'wifi':
      case 'free wifi':
        return Icons.wifi;
      case 'pool':
      case 'swimming pool':
        return Icons.pool;
      case 'spa':
        return Icons.spa;
      case 'private pool':
        return Icons.water;
      case 'yoga classes':
        return Icons.self_improvement;
      case 'beach access':
        return Icons.beach_access;
      case 'butler services':
        return Icons.room_service;
      case 'rooftop bar':
        return Icons.roofing;
      case 'restaurant':
        return Icons.restaurant;
      default:
        return Icons.check_circle_outline;
    }
  }

  // -------------------- BUILD METHOD --------------------
  @override
  Widget build(BuildContext context) {
    final hotel = widget.hotel;

    return Scaffold(
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
                  color: Colors.blue.withOpacity(0.3),
                ),
                Positioned(
                  top: 40,
                  left: 16,
                  child: CircleAvatar(
                    backgroundColor: AppTheme.primaryBlue,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
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
                          icon: const Icon(Icons.share, color: Colors.white),
                          onPressed: () {},
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        child: IconButton(
                          icon: Icon(
                            isLoved ? Icons.favorite : Icons.favorite_border,
                            color: Colors.red,
                          ),
                          onPressed: () => setState(() => isLoved = !isLoved),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ================= HOTEL NAME & LOCATION =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Column(
                  children: [
                    Text(
                      hotel.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 18,
                          color: Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          hotel.location,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ================= PRICE & BOOK BUTTON =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rs ${hotel.pricePerNight.toStringAsFixed(2)} / night',
                    style: const TextStyle(
                      color: AppTheme.primaryBlue,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Total includes taxes & fees',
                    style: TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 12),
                  PrimaryButton(
                    label: 'Book Now',
                    icon: Icons.book_online,
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookingPage(hotel: hotel),
                      ),
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
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(getAmenityIcon(amenity), size: 28),
                      const SizedBox(height: 6),
                      SizedBox(
                        width: 80,
                        child: Text(
                          amenity,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 24),

            // ================= ABOUT HOTEL =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'About this hotel',
                    style: TextStyle(
                      fontSize: 22,
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(hotel.description, style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ================= REVIEWS SECTION =================
            RatingsReviewsSection(
              isLoading: isLoadingReviews,
              reviews: reviews,
              showReviews: true,
              showTitle: true,
            ),

            const SizedBox(height: 32),

            // ================= ADD REVIEW BUTTON =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddReviewPage(hotelId: widget.hotel.hotelId),
                      ),
                    ).then((_) {
                      _loadReviews(); // Refresh reviews after returning
                    });
                  },
                  icon: const Icon(Icons.rate_review),
                  label: const Text(
                    'Add Review and Rating',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color:Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // ================= COMPARE HOTELS BUTTON =================
            Center(
              child: PrimaryButton(
                label: 'Compare Similar',
                icon: Icons.compare_arrows,
                onPressed: isLoadingHotels
                    ? () {} // Do nothing if hotels are still loading
                    : () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CompareHotelsPage(baseHotel: hotel),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
