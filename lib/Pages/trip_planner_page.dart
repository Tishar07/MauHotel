import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://papfdzhkntnfphgraplk.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBhcGZkemhrbnRuZnBoZ3JhcGxrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAzNzEyNzksImV4cCI6MjA3NTk0NzI3OX0.PRz5_0cj4bGmMyObGo3a5q_0fQt1aWA-49sQCRGpLrI',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trip Planner',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const TripPlannerPage(),
    );
  }
}

class TripPlannerPage extends StatefulWidget {
  const TripPlannerPage({super.key});

  @override
  State<TripPlannerPage> createState() => _TripPlannerPageState();
}

class _TripPlannerPageState extends State<TripPlannerPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> trips = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTripsFromSupabase();
  }

  Future<void> fetchTripsFromSupabase() async {
    final response = await supabase
        .from('trips')
        .select()
        .execute(); // ✅ correct

    final data = response.data;

    if (data != null && data is List) {
      setState(() {
        trips = data
            .map<Map<String, dynamic>>(
              (trip) => {
                "id": trip['id'],
                "title": trip['title'],
                "dateRange": trip['date_range'],
                "imageUrl": trip['image_url'],
                "hotelName": trip['hotel_name'],
                "itinerary": parseItinerary(trip['itinerary']),
              },
            )
            .toList();
        isLoading = false;
      });
    } else {
      setState(() {
        trips = [];
        isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> parseItinerary(dynamic raw) {
    if (raw is List) return List<Map<String, dynamic>>.from(raw);
    if (raw is String) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          return List<Map<String, dynamic>>.from(decoded);
        }
      } catch (_) {}
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Trip Planner',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO: Navigate to AddTripPage
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text("Plan Trip"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[900],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ],
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : trips.isEmpty
          ? const Center(child: Text("No trips found."))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: trips.map((trip) => TripCard(trip: trip)).toList(),
              ),
            ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: Colors.blue[900],
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Trip Plan',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'My Profile',
          ),
        ],
      ),
    );
  }
}

class TripCard extends StatelessWidget {
  final Map<String, dynamic> trip;
  const TripCard({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    final itinerary = trip['itinerary'] as List<Map<String, dynamic>>;
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              trip['imageUrl'],
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 180,
                color: Colors.grey[300],
                child: const Center(child: Icon(Icons.broken_image)),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trip['title'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  trip['dateRange'],
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  "Hotel: ${trip['hotelName'] ?? 'N/A'}",
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                if (itinerary.isNotEmpty)
                  ...itinerary.map(
                    (item) => Text("• ${item['day']}: ${item['activity']}"),
                  )
                else
                  const Text("Itinerary: Coming soon..."),
                const SizedBox(height: 10),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Navigate to TripDetailPage
                    },
                    icon: const Icon(Icons.arrow_right_alt),
                    label: const Text('View'),
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
  }
}
