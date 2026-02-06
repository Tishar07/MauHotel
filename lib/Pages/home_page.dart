import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/hotel_model.dart';
import '../models/review_model.dart';
import '../services/homepage_backend.dart';
import '../components/factorybutton.dart';
import '../components/search_bar.dart' as components;
import '../theme/app_theme.dart';
import 'hotel_details_page.dart';
import '../accessibility/accessibility_state.dart';

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

  Future<void> _fetchUserName() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final data = await _supabase
        .from('users')
        .select('first_name, last_name')
        .eq('user_id', user.id)
        .maybeSingle();

    if (!mounted) return;

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
      dynamic query = _supabase.from('hotels').select();

      final search = _searchController.text.trim();
      if (search.isNotEmpty) {
        query = query.ilike('name', '%$search%');
      }

      final category = _selectedFilters['category'];
      final amenity = _selectedFilters['amenity'];

      if (category != null && category.isNotEmpty) {
        query = query.eq('category', category);
      }

      if (amenity != null && amenity.isNotEmpty) {
        query = query.contains('amenities', [amenity]);
      }

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

      if (!mounted) return;
      setState(() => _hotels = hotels);
    } finally {
      if (mounted) setState(() => _isLoading = false);
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

  void _showSortDialog() async {
    final result = await showDialog<String>(
      context: context,
      builder: (_) => SimpleDialog(
        title: Text(AccessibilityState.t('Sort By', 'Trier par')),
        children: [
          _sortOption(
            AccessibilityState.t('Price: Low to High', 'Prix : Croissant'),
            'price_low_to_high',
          ),
          _sortOption(
            AccessibilityState.t('Price: High to Low', 'Prix : Décroissant'),
            'price_high_to_low',
          ),
          _sortOption(
            AccessibilityState.t('Rating: High to Low', 'Note : Décroissante'),
            'rating_high_to_low',
          ),
          _sortOption(
            AccessibilityState.t('Rating: Low to High', 'Note : Croissante'),
            'rating_low_to_high',
          ),
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

  void _showFilterDialog() async {
    String? category;
    String? amenity;

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          AccessibilityState.t('Filter Hotels', 'Filtrer les hôtels'),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: AccessibilityState.t('Category', 'Catégorie'),
              ),
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
              decoration: InputDecoration(
                labelText: AccessibilityState.t('Amenity', 'Équipement'),
              ),
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
            child: Text(AccessibilityState.t('Cancel', 'Annuler')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, {
                'category': category ?? '',
                'amenity': amenity ?? '',
              });
            },
            child: Text(AccessibilityState.t('Apply', 'Appliquer')),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() => _selectedFilters = result);
      _fetchHotels();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AccessibilityState.rebuild,
      builder: (context, _) {
        final highContrast = AccessibilityState.contrast.value >= 2;

        final greeting = _firstName != null
            ? AccessibilityState.t(
                'Welcome to MauHotel,\n$_firstName $_lastName!',
                'Bienvenue à MauHotel,\n$_firstName $_lastName!',
              )
            : AccessibilityState.t(
                'Welcome to MauHotel!',
                'Bienvenue à MauHotel!',
              );

        return Scaffold(
          backgroundColor: highContrast ? Colors.black : Colors.white,
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: _fetchHotels,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: AccessibilityState.padding(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: highContrast ? Colors.white : Colors.black,
                      ),
                    ),
                    SizedBox(height: AccessibilityState.gap(16)),
                    components.SearchBar(
                      controller: _searchController,
                      hintText: AccessibilityState.t(
                        'Search hotels...',
                        'Rechercher des hôtels...',
                      ),
                      onSubmitted: (_) => _fetchHotels(),
                    ),
                    SizedBox(height: AccessibilityState.gap(12)),
                    Row(
                      children: [
                        PrimaryButton(
                          label: AccessibilityState.t('Filter', 'Filtrer'),
                          icon: Icons.filter_list,
                          onPressed: _showFilterDialog,
                        ),
                        SizedBox(width: AccessibilityState.gap(10)),
                        PrimaryButton(
                          label: AccessibilityState.t('Sort', 'Trier'),
                          icon: Icons.sort,
                          onPressed: _showSortDialog,
                        ),
                      ],
                    ),
                    SizedBox(height: AccessibilityState.gap(20)),
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (_hotels.isEmpty)
                      Center(
                        child: Text(
                          AccessibilityState.t(
                            'No hotels found',
                            'Aucun hôtel trouvé',
                          ),
                          style: TextStyle(
                            color: highContrast ? Colors.white : Colors.black,
                          ),
                        ),
                      )
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
      },
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
    return AnimatedBuilder(
      animation: AccessibilityState.rebuild,
      builder: (context, _) {
        final highContrast = AccessibilityState.contrast.value >= 2;

        return Card(
          color: highContrast ? Colors.black : AppTheme.lightBlue,
          margin: EdgeInsets.only(bottom: AccessibilityState.gap(20)),
          child: Padding(
            padding: AccessibilityState.padding(12),
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
                    SizedBox(width: AccessibilityState.gap(12)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hotel.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: highContrast ? Colors.white : Colors.black,
                            ),
                          ),
                          SizedBox(height: AccessibilityState.gap(4)),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 20,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                reviews.isEmpty
                                    ? hotel.ratingAvg.toStringAsFixed(1)
                                    : (reviews.fold<double>(
                                                0,
                                                (sum, r) => sum + r.rating,
                                              ) /
                                              reviews.length)
                                          .toStringAsFixed(1),
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: highContrast
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                AccessibilityState.t(
                                  '(${reviews.length} reviews)',
                                  '(${reviews.length} avis)',
                                ),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: highContrast
                                      ? Colors.white70
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            hotel.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: highContrast
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                          ),
                          SizedBox(height: AccessibilityState.gap(8)),
                          Text(
                            AccessibilityState.t(
                              '${hotel.currency} ${hotel.pricePerNight.toStringAsFixed(0)} per night',
                              '${hotel.currency} ${hotel.pricePerNight.toStringAsFixed(0)} par nuit',
                            ),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: highContrast
                                  ? Colors.white
                                  : AppTheme.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AccessibilityState.gap(12)),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HotelDetailsPage(hotel: hotel),
                      ),
                    ),
                    icon: const Icon(Icons.arrow_forward, size: 16),
                    label: Text(
                      AccessibilityState.t('View Details', 'Voir détails'),
                    ),
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
      },
    );
  }
}
