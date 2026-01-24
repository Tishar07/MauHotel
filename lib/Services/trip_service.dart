import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/trips_model.dart';

class TripService {
  final SupabaseClient supabase;

  TripService(this.supabase);

  Future<void> saveTrip(Trip trip) async {
    try {
      await supabase.from('trips').insert(trip.toJson());
      debugPrint('Trip saved successfully!');
    } catch (e) {
      debugPrint('Error saving trip: $e');
    }
  }

  Future<List<Trip>> fetchTrips() async {
    try {
      final response = await supabase.from('trips').select();
      debugPrint('Raw trips response: $response');

      final data = (response as List<dynamic>?) ?? [];
      return data.map((json) => Trip.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching trips: $e');
      return [];
    }
  }
}
