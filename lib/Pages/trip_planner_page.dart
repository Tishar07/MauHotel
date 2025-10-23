import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/hotel_model.dart';

class TripPlannerPage extends StatefulWidget {
  const TripPlannerPage({super.key});

  @override
  State<TripPlannerPage> createState() => _TripPlannerPageState();
}

class _TripPlannerPageState extends State<TripPlannerPage> {
  final supabase = Supabase.instance.client;
  List<Hotel> hotels = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchHotelsFromSupabase();
  }

  Future<void> fetchHotelsFromSupabase() async {
    setState(() => isLoading = true);
    try {
      final response = await supabase.from('hotels').select('*');
      if (response is List && response.isNotEmpty) {
        setState(() {
          hotels = response.map((json) => Hotel.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          hotels = [];
          isLoading = false;
        });
      }
    } catch (e, st) {
      debugPrint('❌ Error fetching hotels: $e\n$st');
      setState(() {
        hotels = [];
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Error fetching hotels.")));
    }
  }

  Future<void> showDayInputDialog(Hotel hotel) async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Plan Trip for ${hotel.name}"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "Enter number of days"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final days = int.tryParse(controller.text);
              if (days != null && days > 0) {
                Navigator.pop(context);
                generateItinerary(hotel, days);
              }
            },
            child: const Text("Generate"),
          ),
        ],
      ),
    );
  }

  Future<void> generateItinerary(Hotel hotel, int days) async {
    final itinerary = List.generate(
      days,
      (i) => {
        "day": "Day ${i + 1}",
        "activity": "Explore local attractions near ${hotel.name}",
      },
    );

    final trip = {
      "title": "${hotel.name} Trip",
      "date_range": "Flexible",
      "image_url": hotel.imageUrl,
      "hotel_name": hotel.name,
      "itinerary": itinerary,
    };

    try {
      await supabase.from('trips').insert(trip);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Trip created successfully!")),
      );
    } catch (e, st) {
      debugPrint("❌ Error saving trip: $e\n$st");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to create trip.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    const lightBlue = Color(0xFFE8F3FF);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Trip Planner",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hotels.isEmpty
          ? const Center(child: Text("No hotels found."))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: hotels.length,
              itemBuilder: (_, index) {
                final hotel = hotels[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: lightBlue,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            hotel.imageUrl,
                            width: 100,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 100,
                              height: 80,
                              color: Colors.grey[300],
                              child: const Icon(Icons.broken_image),
                            ),
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
                              const SizedBox(height: 6),
                              Text(
                                hotel.description ??
                                    "No description available.",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 13),
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton.icon(
                                  onPressed: () => showDayInputDialog(hotel),
                                  icon: const Icon(Icons.add, size: 16),
                                  label: const Text("Plan Trip"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue[800],
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 18,
                                      vertical: 8,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
