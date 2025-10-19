import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mauhotel/Pages/hotel_details_page.dart';

// --------------------- MODEL ---------------------
class Hotel {
  final String name;
  final double rating;
  final int reviews;
  final String description;
  final String offer;
  final String price;
  final String imageUrl;

  Hotel({
    required this.name,
    required this.rating,
    required this.reviews,
    required this.description,
    required this.offer,
    required this.price,
    required this.imageUrl,
  });

  factory Hotel.fromJson(Map<String, dynamic> json) {
    return Hotel(
      name: json['name'] ?? 'Unknown Hotel',
      rating: (json['overall_rating'] ?? 0).toDouble(),
      reviews: json['reviews'] ?? 0,
      description: json['description'] ?? 'No description available',
      offer: (json['offers'] != null && json['offers'].isNotEmpty)
          ? json['offers'][0]['name'] ?? ''
          : '',
      price: json['rate_per_night']?['lowest']?.toString() ?? 'N/A',
      imageUrl: (json['images'] != null &&
              json['images'] is List &&
              json['images'].isNotEmpty)
          ? json['images'][0]['thumbnail'] ??
              'https://via.placeholder.com/150'
          : 'https://via.placeholder.com/150',
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
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  List<Hotel> _hotels = [];
  bool _isLoading = false;

  String? _selectedSort;
  Map<String, String>? _selectedFilters;
  String _currentLocation = 'Mauritius';

  @override
  void initState() {
    super.initState();
    _fetchHotels();
  }

  Future<void> _fetchHotels() async {
    setState(() => _isLoading = true);

    try {
      final List<Hotel> fetched = await _fetchHotelsFromAPI(
        location: _currentLocation,
        sortBy: _selectedSort,
        filters: _selectedFilters,
      );

      setState(() => _hotels = fetched);
    } catch (e) {
      debugPrint('Error fetching hotels: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error fetching hotels')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // -------------------- FIXED API CALL --------------------
  Future<List<Hotel>> _fetchHotelsFromAPI({
    String location = 'Mauritius',
    String checkIn = '2025-10-20',
    String checkOut = '2025-10-25',
    String? sortBy,
    Map<String, String>? filters,
  }) async {
    const apiKey =
        '4c070bb676cd781d2fe522303df7cffe7fe980637552629de069c59bfacb08d5';

    final Map<String, String> queryParams = {
      'engine': 'google_hotels',
      'q': location,
      'check_in_date': checkIn,
      'check_out_date': checkOut,
      'api_key': apiKey,
    };

    // Supported sort_by codes
    if (sortBy != null && sortBy != 'price_high_to_low') {
      final mapped = _mapSortOption(sortBy);
      if (mapped != null) queryParams['sort_by'] = mapped;
    }

    // Add supported filters
    if (filters != null) {
      if (filters['hotel_class'] != null &&
          filters['hotel_class']!.isNotEmpty) {
        queryParams['hotel_class'] = filters['hotel_class']!;
      }
      if (filters['amenity'] != null && filters['amenity']!.isNotEmpty) {
        final amen = _mapAmenity(filters['amenity']!);
        final serpFilters = <String, dynamic>{
          'amenities': [amen],
        };
        queryParams['filters'] = jsonEncode(serpFilters);
      }
    }

    final uri = Uri.https('serpapi.com', '/search.json', queryParams);
    debugPrint('Request URL: $uri');

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['properties'] as List? ?? [];
      final List<Hotel> fetched =
          results.map((json) => Hotel.fromJson(json)).toList();

      // Local sort fallback for price_high_to_low
      if (sortBy == 'price_high_to_low') {
        fetched.sort((a, b) {
          final pa =
              double.tryParse(a.price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
          final pb =
              double.tryParse(b.price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
          return pb.compareTo(pa);
        });
      }

      return fetched;
    } else {
      debugPrint('SerpApi response: ${response.body}');
      throw Exception('Failed to load hotels: ${response.statusCode}');
    }
  }

  String? _mapSortOption(String key) {
    switch (key) {
      case 'price_low_to_high':
        return '3'; // Lowest price
      case 'rating_high_to_low':
        return '8'; // Highest rating
      case 'most_reviewed':
        return '13'; // Most reviewed
      default:
        return null;
    }
  }

  String _mapAmenity(String key) {
    switch (key) {
      case 'wifi':
        return 'Free Wi-Fi';
      case 'pool':
        return 'Pool';
      case 'spa':
        return 'Spa';
      case 'parking':
        return 'Free parking';
      case 'breakfast':
        return 'Free breakfast';
      default:
        return key;
    }
  }

  // -------------------- SORT & FILTER UI --------------------
  void _showSortDialog() async {
    final option = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Sort By'),
        children: [
          SimpleDialogOption(
            child: const Text('Price: Low to High'),
            onPressed: () => Navigator.pop(context, 'price_low_to_high'),
          ),
          SimpleDialogOption(
            child: const Text('Price: High to Low'),
            onPressed: () => Navigator.pop(context, 'price_high_to_low'),
          ),
          SimpleDialogOption(
            child: const Text('Rating: High to Low'),
            onPressed: () => Navigator.pop(context, 'rating_high_to_low'),
          ),
          SimpleDialogOption(
            child: const Text('Most Reviewed'),
            onPressed: () => Navigator.pop(context, 'most_reviewed'),
          ),
        ],
      ),
    );

    if (option != null) {
      setState(() => _selectedSort = option);
      _fetchHotels();
    }
  }

  void _showFilterDialog() async {
    String? hotelClass;
    String? amenity;

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filter Hotels'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Hotel Class'),
                  items: const [
                    DropdownMenuItem(value: '3', child: Text('3-Star')),
                    DropdownMenuItem(value: '4', child: Text('4-Star')),
                    DropdownMenuItem(value: '5', child: Text('5-Star')),
                  ],
                  onChanged: (val) => hotelClass = val,
                ),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Amenity'),
                  items: const [
                    DropdownMenuItem(value: 'wifi', child: Text('Free Wi-Fi')),
                    DropdownMenuItem(value: 'pool', child: Text('Pool')),
                    DropdownMenuItem(value: 'spa', child: Text('Spa')),
                    DropdownMenuItem(
                        value: 'parking', child: Text('Free Parking')),
                    DropdownMenuItem(
                        value: 'breakfast',
                        child: Text('Breakfast Included')),
                  ],
                  onChanged: (val) => amenity = val,
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
                  'hotel_class': hotelClass ?? '',
                  'amenity': amenity ?? '',
                });
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      setState(() => _selectedFilters = result);
      _fetchHotels();
    }
  }

  // -------------------- UI --------------------
  @override
  Widget build(BuildContext context) {
    const String userName = 'Naga Pushkaar';

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to MauHotel,\n$userName!',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Search field
            TextField(
              controller: _searchController,
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  setState(() => _currentLocation = value.trim());
                  _fetchHotels();
                }
              },
              decoration: InputDecoration(
                hintText: 'Search location...',
                prefixIcon: const Icon(Icons.search),
                fillColor: Colors.blue.shade50,
                filled: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
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
                  label: const Text("Filter"),
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
                  label: const Text("Sort"),
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

            _isLoading
                ? const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  )
                : Expanded(
                    child: _hotels.isEmpty
                        ? const Center(child: Text('No hotels found'))
                        : ListView.builder(
                            controller: _scrollController,
                            itemCount: _hotels.length,
                            itemBuilder: (context, index) {
                              final hotel = _hotels[index];
                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                color: Colors.blue.shade50,
                                margin: const EdgeInsets.only(bottom: 20),
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        child: Image.network(
                                          hotel.imageUrl,
                                          height: 100,
                                          width: 100,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Container(
                                            height: 100,
                                            width: 100,
                                            color: Colors.grey,
                                            child: const Icon(Icons.image),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              hotel.name,
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight:
                                                      FontWeight.bold),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(Icons.star,
                                                    color: Colors.orange,
                                                    size: 16),
                                                Text('${hotel.rating}/5',
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                const SizedBox(width: 8),
                                                Text(
                                                  'Reviews (${hotel.reviews})',
                                                  style: const TextStyle(
                                                      color: Colors.grey),
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
                                                  hotel.offer,
                                                  style: const TextStyle(
                                                      color: Colors.red,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                const SizedBox(width: 10),
                                                Text(
                                                  hotel.price,
                                                  style: TextStyle(
                                                      color:
                                                          Colors.blue.shade800,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: ElevatedButton(
                                          onPressed: () {},
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Colors.blue.shade800,
                                            shape: const CircleBorder(),
                                            padding:
                                                const EdgeInsets.all(12),
                                          ),
                                          child:
                                              const Icon(Icons.arrow_forward),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
          ],
        ),
      ),
    );
  }
}
