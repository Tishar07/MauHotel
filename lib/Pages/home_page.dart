import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'hotel_details_page.dart';

// --------------------- MODEL ---------------------
class Hotel {
  final int id;
  final String name;
  final String description;
  final double pricePerNight;
  final String currency;
  final String category;
  final String imageUrl;
  final double rating;
  final int reviews;

  Hotel({
    required this.id,
    required this.name,
    required this.description,
    required this.pricePerNight,
    required this.currency,
    required this.category,
    required this.imageUrl,
    required this.rating,
    required this.reviews,
  });

  factory Hotel.fromJson(Map<String, dynamic> json) {
    return Hotel(
      id: json['hotel_id'] ?? 0,
      name: json['name'] ?? 'Unknown Hotel',
      description: json['description'] ?? '',
      pricePerNight: (json['price_per_night'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'MUR',
      category: json['category'] ?? '',
      imageUrl: json['image_url'] ?? 'assets/Hotel_images/placeholder.jpg',
      rating: (json['rating_avg'] ?? 0).toDouble(),
      reviews: json['reviews'] ?? 0,
    );
  }
}

// --------------------- PAGE ---------------------
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final supabase = Supabase.instance.client;
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;

  List<Hotel> _hotels = [];
  String? _selectedSort;
  Map<String, String> _selectedFilters = {};

  String? _firstName;
  String? _lastName;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    _fetchHotels();
  }

  // --------------------- FETCH USER ---------------------
  Future<void> _fetchUserName() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final response = await supabase
          .from('users')
          .select('first_name, last_name')
          .eq('user_id', user.id)
          .maybeSingle();

      if (response != null) {
        setState(() {
          _firstName = response['first_name'];
          _lastName = response['last_name'];
        });
      }
    } catch (e) {
      debugPrint('❌ Error fetching user: $e');
    }
  }

  // --------------------- FETCH HOTELS ---------------------
  Future<void> _fetchHotels() async {
    setState(() => _isLoading = true);

    try {
      final query = supabase.from('hotels').select();

      final category = _selectedFilters['category'];
      final amenity = _selectedFilters['amenity'];

      // Apply filters
      if (category != null && category.isNotEmpty) {
        query.eq('category', category);
      }
      if (amenity != null && amenity.isNotEmpty) {
        query.contains('amenities', [amenity]);
      }

      // Sorting
      switch (_selectedSort) {
        case 'price_low_to_high':
          query.order('price_per_night', ascending: true);
          break;
        case 'price_high_to_low':
          query.order('price_per_night', ascending: false);
          break;
        case 'rating_high_to_low':
          query.order('rating_avg', ascending: false);
          break;
        case 'rating_low_to_high':
          query.order('rating_avg', ascending: true);
          break;
      }

      final data = await query;
      final hotels = (data as List).map((e) => Hotel.fromJson(e)).toList();

      setState(() => _hotels = hotels);
    } catch (e, st) {
      debugPrint('❌ Fetch error: $e\n$st');
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Error fetching hotels')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // --------------------- SORT DIALOG ---------------------
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

  // --------------------- FILTER DIALOG ---------------------
  void _showFilterDialog() async {
    String? category;
    String? amenity;

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Filter Hotels'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Category'),
                items: const [
                  DropdownMenuItem(value: 'Luxury', child: Text('Luxury')),
                  DropdownMenuItem(value: 'Budget-Friendly', child: Text('Budget-Friendly')),
                  DropdownMenuItem(value: 'Adventure', child: Text('Adventure')),
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
                  DropdownMenuItem(value: 'Restaurant', child: Text('Restaurant')),
                ],
                onChanged: (v) => amenity = v,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
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

  // --------------------- UI BUILD ---------------------
  @override
  Widget build(BuildContext context) {
    final userGreeting = _firstName != null
        ? 'Welcome to MauHotel,\n$_firstName $_lastName!'
        : 'Welcome to MauHotel!';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userGreeting,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                onSubmitted: (val) => _fetchHotels(),
                decoration: InputDecoration(
                  hintText: 'Hotels...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.blue.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _showFilterDialog,
                    icon: const Icon(Icons.filter_list),
                    label: const Text('Filter By'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade800,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: _showSortDialog,
                    icon: const Icon(Icons.sort),
                    label: const Text('Sort By'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade800,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _hotels.isEmpty
                        ? const Center(child: Text('No hotels found'))
                        : ListView.builder(
                            itemCount: _hotels.length,
                            itemBuilder: (_, i) =>
                                _buildHotelCard(_hotels[i]),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --------------------- HOTEL CARD ---------------------
  Widget _buildHotelCard(Hotel hotel) {
    return Card(
      color: Colors.blue.shade50,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHotelImage(hotel.imageUrl),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hotel.name,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star,
                          color: Colors.orange, size: 16),
                      Text(
                        '${hotel.rating.toStringAsFixed(1)}/5',
                        style:
                            const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Reviews (${hotel.reviews})',
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hotel.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        'Rs ${hotel.pricePerNight.toStringAsFixed(0)} per night',
                        style: TextStyle(
                          color: Colors.blue.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: () {
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade800,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25)),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        icon: const Icon(Icons.arrow_forward, size: 16),
                        label: const Text('View'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------- IMAGE LOADER ---------------------
  Widget _buildHotelImage(String url) {
    final isNetwork = url.startsWith('http') || url.startsWith('https');
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: isNetwork
          ? Image.network(
              url,
              height: 100,
              width: 100,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _imagePlaceholder(),
            )
          : Image.asset(
              url,
              height: 100,
              width: 100,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _imagePlaceholder(),
            ),
    );
  }

  Widget _imagePlaceholder() => Container(
        height: 100,
        width: 100,
        color: Colors.grey.shade200,
        child: const Icon(Icons.broken_image, color: Colors.grey),
      );
}
