import 'package:flutter/material.dart';


class TripPlannerPage extends StatefulWidget {
  const TripPlannerPage({Key? key}) : super(key: key);

  @override
  State<TripPlannerPage> createState() => _TripPlannerPageState();
}

class _TripPlannerPageState extends State<TripPlannerPage> {
  // Example static trip list — replace later with Supabase data
  final List<Map<String, dynamic>> trips = [
    {
      "title": "Grand Baie Trip",
      "dateRange": "20 Dec - 31 Dec 2025",
      "imageUrl": "https://images.unsplash.com/photo-1501117716987-c8e1ecb2101f",
    },
  ];

  @override
  void initState() {
    super.initState();
    // TODO: Fetch trips from Supabase here
    // Example:
    // fetchTripsFromSupabase();
  }

  // Example method for fetching trips
  Future<void> fetchTripsFromSupabase() async {
    // TODO: Implement Supabase query, e.g.:
    // final response = await supabase.from('trips').select();
    // setState(() => trips = response);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ✅ App bar
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Trip Planner',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO: Navigate to "Add Trip" page
                // Navigator.push(context, MaterialPageRoute(builder: (_) => AddTripPage()));
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

      // ✅ Main content area
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: trips.map((trip) => TripCard(trip: trip)).toList(),
        ),
      ),

      // ✅ Include the Bottom Navigation Bar

    );
  }
}

// ✅ Card widget for each trip
class TripCard extends StatelessWidget {
  final Map<String, dynamic> trip;
  const TripCard({Key? key, required this.trip}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                const SizedBox(height: 10),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Navigate to detailed trip page
                      // Navigator.push(context, MaterialPageRoute(builder: (_) => TripDetailPage(tripId: trip['id'])));
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
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
