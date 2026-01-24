import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/hotel_model.dart';
import '../models/review_model.dart';
import '../services/homepage_backend.dart';
import '../components/factorybutton.dart';
import '../components/search_bar.dart' as components;
import '../components/ratings_reviews_section.dart';
import '../theme/app_theme.dart';
import 'hotel_details_page.dart';

// -------------------- HOME PAGE --------------------
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SupabaseClient _supabase = Supabase.instance.client;
  final HotelService _hotelService = HotelService();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = false;
  List<Hotel> _hotels = [];
  Map<int, List<Review>> _hotelReviews = {};
  Map<int, bool> _reviewsLoading = {};

  String? _firstName;
  String? _lastName;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    _fetchHotels();
  }

  Future<void> _fetchUserName() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final data = await _supabase
        .from('users')
        .select('first_name, last_name')
        .eq('user_id', user.id)
        .maybeSingle();

    if (data != null) {
      setState(() {
        _firstName = data['first_name'];
        _lastName = data['last_name'];
      });
    }
  }

  Future<void> _fetchHotels() async {
    setState(() => _isLoading = true);

    try {
      final hotels = await _hotelService.fetchHotels();

      for (var hotel in hotels) {
        _reviewsLoading[hotel.hotelId] = true;
        _hotelReviews[hotel.hotelId] = [];
        _fetchReviews(hotel.hotelId);
      }

      setState(() => _hotels = hotels);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchReviews(int hotelId) async {
    final reviews = await _hotelService.fetchReviews(hotelId);
    if (!mounted) return;

    setState(() {
      _hotelReviews[hotelId] = reviews;
      _reviewsLoading[hotelId] = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final greeting = _firstName != null
        ? 'Welcome to MauHotel,\n$_firstName $_lastName!'
        : 'Welcome to MauHotel!';

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchHotels,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                components.SearchBar(
                  controller: _searchController,
                  hintText: 'Search hotels...',
                  onSubmitted: (_) => _fetchHotels(),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    PrimaryButton(
                      label: 'Filter',
                      icon: Icons.filter_list,
                      onPressed: () {},
                    ),
                    const SizedBox(width: 10),
                    PrimaryButton(
                      label: 'Sort',
                      icon: Icons.sort,
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (_hotels.isEmpty)
                  const Center(child: Text('No hotels found'))
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _hotels.length,
                    itemBuilder: (_, i) {
                      final hotel = _hotels[i];
                      return _HotelCard(
                        hotel: hotel,
                        isLoadingReviews:
                            _reviewsLoading[hotel.hotelId] ?? true,
                        reviews: _hotelReviews[hotel.hotelId] ?? [],
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HotelCard extends StatelessWidget {
  final Hotel hotel;
  final bool isLoadingReviews;
  final List<Review> reviews;

  const _HotelCard({
    required this.hotel,
    required this.isLoadingReviews,
    required this.reviews,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.lightBlue,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // -------------------- IMAGE + INFO --------------------
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: hotel.imageUrl.startsWith('http')
                      ? Image.network(
                          hotel.imageUrl,
                          height: 100,
                          width: 120,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          hotel.imageUrl,
                          height: 100,
                          width: 120,
                          fit: BoxFit.cover,
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
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hotel.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${hotel.currency} ${hotel.pricePerNight.toStringAsFixed(0)} per night',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // -------------------- REVIEWS --------------------
            RatingsReviewsSection(
              isLoading: isLoadingReviews,
              reviews: reviews,
              showReviews: false,
              showTitle: false,
            ),

            const SizedBox(height: 8),

            // -------------------- BUTTON --------------------
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HotelDetailsPage(hotel: hotel),
                    ),
                  );
                },
                icon: const Icon(Icons.arrow_forward, size: 16),
                label: const Text('View Details'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
