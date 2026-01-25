import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/hotel_model.dart';
import '../models/review_model.dart';
import '../services/homepage_backend.dart';
import '../components/factorybutton.dart';
import '../components/search_bar.dart' as components;
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

  String _selectedSort = 'price_low_to_high';
  Map<String, String> _selectedFilters = {};

  String? _firstName;
  String? _lastName;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    _fetchHotels();
  }

  // -------------------- USER NAME --------------------
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

  // -------------------- FETCH HOTELS --------------------
  Future<void> _fetchHotels() async {
    setState(() => _isLoading = true);

    try {
      dynamic query = _supabase.from('hotels').select();

      // -------- SEARCH --------
      final search = _searchController.text.trim();
      if (search.isNotEmpty) {
        query = query.ilike('name', '%$search%');
      }

      // -------- FILTERS --------
      final category = _selectedFilters['category'];
      final amenity = _selectedFilters['amenity'];

      if (category != null && category.isNotEmpty) {
        query = query.eq('category', category);
      }

      if (amenity != null && amenity.isNotEmpty) {
        query = query.contains('amenities', [amenity]);
      }

      // -------- SORT --------
      switch (_selectedSort) {
        case 'price_low_to_high':
          query = query.order('price_per_night', ascending: true);
          break;
        case 'price_high_to_low':
          query = query.order('price_per_night', ascending: false);
          break;
        case 'rating_high_to_low':
          query = query.order('rating_avg', ascending: false);
          break;
        case 'rating_low_to_high':
          query = query.order('rating_avg', ascending: true);
          break;
      }

      final data = await query;
      final hotels = (data as List).map((e) => Hotel.fromJson(e)).toList();

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

  // -------------------- FETCH REVIEWS --------------------
  Future<void> _fetchReviews(int hotelId) async {
    final reviews = await _hotelService.fetchReviews(hotelId);
    if (!mounted) return;

    setState(() {
      _hotelReviews[hotelId] = reviews;
      _reviewsLoading[hotelId] = false;
    });
  }

  // -------------------- SORT DIALOG --------------------
  void _showSortDialog() async {
    final result = await showDialog<String>(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('Sort By'),
        children: [
          _sortOption('Price: Low to High', 'price_low_to_high'),
          _sortOption('Price: High to Low', 'price_high_to_low'),
          _sortOption('Rating: High to Low', 'rating_high_to_low'),
          _sortOption('Rating: Low to High', 'rating_low_to_high'),
        ],
      ),
    );

    if (result != null) {
      setState(() => _selectedSort = result);
      _fetchHotels();
    }
  }

  SimpleDialogOption _sortOption(String title, String value) =>
      SimpleDialogOption(
        child: Text(title),
        onPressed: () => Navigator.pop(context, value),
      );

  // -------------------- FILTER DIALOG --------------------
  void _showFilterDialog() async {
    String? category;
    String? amenity;

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Filter Hotels'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Category'),
              items: const [
                DropdownMenuItem(value: 'Luxury', child: Text('Luxury')),
                DropdownMenuItem(
                  value: 'Budget-Friendly',
                  child: Text('Budget-Friendly'),
                ),
                DropdownMenuItem(value: 'Resort', child: Text('Resort')),
              ],
              onChanged: (v) => category = v,
            ),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Amenity'),
              items: const [
                DropdownMenuItem(value: 'WiFi', child: Text('Wi-Fi')),
                DropdownMenuItem(value: 'Pool', child: Text('Pool')),
                DropdownMenuItem(value: 'Spa', child: Text('Spa')),
              ],
              onChanged: (v) => amenity = v,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, {
                'category': category ?? '',
                'amenity': amenity ?? '',
              });
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() => _selectedFilters = result);
      _fetchHotels();
    }
  }

  // -------------------- UI --------------------
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
                      onPressed: _showFilterDialog,
                    ),
                    const SizedBox(width: 10),
                    PrimaryButton(
                      label: 'Sort',
                      icon: Icons.sort,
                      onPressed: _showSortDialog,
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

// -------------------- HOTEL CARD --------------------
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
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: hotel.imageUrl.startsWith('http')
                      ? Image.network(
                          hotel.imageUrl,
                          height: 120,
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
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            reviews.isEmpty
                                ? hotel.ratingAvg.toStringAsFixed(1)
                                : (reviews.fold(
                                            0.0,
                                            (sum, r) => sum + r.rating,
                                          ) /
                                          reviews.length)
                                      .toStringAsFixed(1),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '(${reviews.length} reviews)',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
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
