import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TripPlannerPage extends StatefulWidget {
  const TripPlannerPage({super.key});

  @override
  State<TripPlannerPage> createState() => _TripPlannerPageState();
}

class _TripPlannerPageState extends State<TripPlannerPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> hotels = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchHotelsFromSupabase();
  }

  // ✅ FETCH HOTELS FROM SUPABASE (clean & safe)
  Future<void> fetchHotelsFromSupabase() async {
    setState(() => isLoading = true);
    try {
      final response = await supabase
          .from('hotels')
          .select('hotel_id, name, image_url'); // pick only what you need

      if (response is List && response.isNotEmpty) {
        setState(() {
          hotels = response
              .map<Map<String, dynamic>>(
                (hotel) => {
                  "id": hotel['hotel_id'] ?? 0,
                  "name": hotel['name'] ?? 'Unnamed Hotel',
                  "imageUrl":
                      hotel['image_url'] ??
                      'https://via.placeholder.com/300x180?text=No+Image',
                },
              )
              .toList();
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

  // 🔹 Ask user for days
  Future<void> showDayInputDialog(Map<String, dynamic> hotel) async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Plan Trip for ${hotel['name']}"),
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

  // 🔹 Generate and save trip itinerary
  Future<void> generateItinerary(Map<String, dynamic> hotel, int days) async {
    final itinerary = List.generate(
      days,
      (i) => {
        "day": "Day ${i + 1}",
        "activity": "Explore local attractions near ${hotel['name']}",
      },
    );

    final trip = {
      "title": "${hotel['name']} Trip",
      "date_range": "Flexible",
      "image_url": hotel['imageUrl'],
      "hotel_name": hotel['name'],
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

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Trip Planner",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hotels.isEmpty
          ? const Center(child: Text("No hotels found."))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: hotels.length,
              itemBuilder: (_, index) {
                final hotel = hotels[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: Image.network(
                          hotel['imageUrl'] ?? '',
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 180,
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(Icons.broken_image),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hotel['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Center(
                              child: ElevatedButton.icon(
                                onPressed: () => showDayInputDialog(hotel),
                                icon: const Icon(Icons.add),
                                label: const Text("Plan Trip"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue[900],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
