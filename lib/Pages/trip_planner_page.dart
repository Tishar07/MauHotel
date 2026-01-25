import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/hotel_model.dart';
import '../services/hotel_service.dart';
import '../theme/app_theme.dart';

class TripPlannerPage extends StatefulWidget {
  const TripPlannerPage({super.key});

  @override
  State<TripPlannerPage> createState() => _TripPlannerPageState();
}

class _TripPlannerPageState extends State<TripPlannerPage> {
  final HotelService _hotelService = HotelService(Supabase.instance.client);

  final TextEditingController _searchController = TextEditingController();

  List<Hotel> _hotels = [];
  Hotel? _selectedHotel;

  bool _isLoading = true;
  bool _isViewing = false;

  @override
  void initState() {
    super.initState();
    _fetchHotels();
  }

  Future<void> _fetchHotels() async {
    _hotels = await _hotelService.fetchHotels();
    setState(() => _isLoading = false);
  }

  void _onSearch(String value) {
    if (value.isEmpty) {
      setState(() => _selectedHotel = null);
      return;
    }

    try {
      final match = _hotels.firstWhere(
        (h) => h.name.toLowerCase().contains(value.toLowerCase()),
      );
      setState(() => _selectedHotel = match);
    } catch (_) {
      setState(() => _selectedHotel = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // 🔹 APP BAR
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "Trip Planner",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              onPressed: _selectedHotel == null ? null : () {},
              icon: const Icon(Icons.add),
              label: const Text("Plan Trip"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
        ],
      ),

      // 🔹 BODY
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // 🔍 SEARCH BOX
                  TextField(
                    controller: _searchController,
                    onChanged: _onSearch,
                    decoration: InputDecoration(
                      hintText: "Search hotel...",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: const Color(0xFFF2F4F7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 🏨 HOTEL CARD OR EMPTY STATE
                  _selectedHotel == null
                      ? const Text(
                          "Search and select a hotel to plan your trip",
                          style: TextStyle(color: Colors.grey),
                        )
                      : _buildHotelCard(_selectedHotel!),
                ],
              ),
            ),
    );
  }

  // 🔹 SINGLE HOTEL CARD (matches UI)
  Widget _buildHotelCard(Hotel hotel) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.network(
            hotel.imageUrl,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              height: 200,
              color: Colors.grey.shade300,
              child: const Icon(Icons.broken_image, size: 40),
            ),
          ),
        ),

        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F3FF),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      hotel.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Text(
                    "20 Dec - 31 Dec 2025",
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // 👀 VIEW BUTTON WITH LOADING
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isViewing
                      ? null
                      : () async {
                          setState(() => _isViewing = true);

                          await Future.delayed(const Duration(seconds: 2));

                          setState(() => _isViewing = false);

                          // Navigation will be added later
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: _isViewing
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "→ View",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
