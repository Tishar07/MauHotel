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

  Future<void> fetchHotelsFromSupabase() async {
    try {
      final data = await supabase.from('hotels').select();

      if (data != null && data is List) {
        setState(() {
          hotels = data
              .map<Map<String, dynamic>>(
                (hotel) => {
                  "id": hotel['id'],
                  "name": hotel['name'],
                  "imageUrl": hotel['image_url'],
                },
              )
              .toList();
          isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error fetching hotels: $e');
      setState(() {
        hotels = [];
        isLoading = false;
      });
    }
  }

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
      await supabase.from('trips').insert({
        "title": trip['title'],
        "date_range": trip['date_range'],
        "image_url": trip['image_url'],
        "hotel_name": trip['hotel_name'],
        "itinerary": itinerary,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Trip created successfully!")),
      );
    } catch (e) {
      print("❌ Error saving trip: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to create trip.")));
    }
  }

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
