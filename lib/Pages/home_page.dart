import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'hotel_view_page.dart';

class Hotel {
  final int id;
  final String name;
  final String description;
  final double pricePerNight;
  final String currency;
  final String category;
  final String imageUrl;
  double rating; // now mutable so we can update after fetching reviews
  int reviews;

  Hotel({
    required this.id,
    required this.name,
    required this.description,
    required this.pricePerNight,
    required this.currency,
    required this.category,
    required this.imageUrl,
    this.rating = 0,
    this.reviews = 0,
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
    );
  }
}

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
      debugPrint('Error fetching user: $e');
    }
  }

  Future<void> _fetchHotels() async {
    setState(() => _isLoading = true);

    try {
      dynamic query = supabase.from('hotels').select();

      final category = _selectedFilters['category'];
      final amenity = _selectedFilters['amenity'];
      final search = _searchController.text.trim();

      if (category != null && category.isNotEmpty) {
        query = query.eq('category', category);
      }

      if (amenity != null && amenity.isNotEmpty) {
        query = query.contains('amenities', [amenity]);
      }

      if (search.isNotEmpty) {
        query = query.ilike('name', '%$search%');
      }

      // Sorting logic
      switch (_selectedSort) {
        case 'price_low_to_high':
          query = query.order('price_per_night', ascending: true);
          break;
        case 'price_high_to_low':
          query = query.order('price_per_night', ascending: false);
          break;
      }

      final data = await query;
      final hotels = (data as List).map((e) => Hotel.fromJson(e)).toList();

      // Now fetch review data for each hotel
      await _fetchReviewsForHotels(hotels);

      setState(() => _hotels = hotels);
    } catch (e, st) {
      debugPrint('Fetch error: $e\n$st');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error fetching hotels')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchReviewsForHotels(List<Hotel> hotels) async {
    try {
      final hotelIds = hotels.map((h) => h.id).toList();
      final response = await supabase
          .from('reviews')
          .select('hotel_id, rating')
          .inFilter('hotel_id', hotelIds);

      final List<dynamic> reviewsData = response as List<dynamic>;

      // Group and calculate average
      for (final hotel in hotels) {
        final hotelReviews = reviewsData
            .where((r) => r['hotel_id'] == hotel.id)
            .toList();

        if (hotelReviews.isNotEmpty) {
          final totalRating = hotelReviews
              .map((r) => (r['rating'] ?? 0).toDouble())
              .reduce((a, b) => a + b);
          final avgRating = totalRating / hotelReviews.length;
          hotel.rating = avgRating;
          hotel.reviews = hotelReviews.length;
        } else {
          hotel.rating = 0;
          hotel.reviews = 0;
        }
      }
    } catch (e) {
      debugPrint('Error fetching review data: $e');
    }
  }

  void _showSortDialog() async {
    final result = await showDialog<String>(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('Sort By'),
        children: [
          _sortOption('Price: Low to High', 'price_low_to_high'),
          _sortOption('Price: High to Low', 'price_high_to_low'),
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
        title: const Text('Filter Hotels'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Category'),
                items: const [
                  DropdownMenuItem(value: 'Luxury', child: Text('Luxury')),
                  DropdownMenuItem(
                    value: 'Budget-Friendly',
                    child: Text('Budget-Friendly'),
                  ),
                  DropdownMenuItem(
                    value: 'Adventure',
                    child: Text('Adventure'),
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
                  DropdownMenuItem(
                    value: 'Restaurant',
                    child: Text('Restaurant'),
                  ),
                ],
                onChanged: (v) => amenity = v,
              ),
            ],
          ),
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
                onSubmitted: (_) => _fetchHotels(),
                decoration: InputDecoration(
                  hintText: 'Search hotels...',
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
                        itemBuilder: (_, i) => _buildHotelCard(_hotels[i]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHotelCard(Hotel hotel) {
    return Card(
      color: Colors.blue.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.only(bottom: 25),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHotelImage(hotel.imageUrl, height: 140, width: 140),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hotel.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.orange, size: 18),
                      Text(
                        '${hotel.rating.toStringAsFixed(1)}/5',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${hotel.reviews} reviews)',
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    hotel.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        'Rs ${hotel.pricePerNight.toStringAsFixed(0)} per night',
                        style: TextStyle(
                          color: Colors.blue.shade800,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  HotelViewPage(hotelId: hotel.id.toString()),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(
                            21,
                            101,
                            192,
                            1,
                          ),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                        ),
                        icon: const Icon(Icons.arrow_forward, size: 18),
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

  Widget _buildHotelImage(
    String url, {
    double height = 120,
    double width = 120,
  }) {
    final isNetwork = url.startsWith('http') || url.startsWith('https');
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: isNetwork
          ? Image.network(
              url,
              height: height,
              width: width,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _imagePlaceholder(height, width),
            )
          : Image.asset(
              url,
              height: height,
              width: width,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _imagePlaceholder(height, width),
            ),
    );
  }

  Widget _imagePlaceholder(double height, double width) => Container(
    height: height,
    width: width,
    color: const Color.fromARGB(255, 255, 255, 255),
    child: const Icon(Icons.broken_image, color: Colors.grey),
  );
}
