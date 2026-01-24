import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/hotel_model.dart';

class HotelService {
  final SupabaseClient supabase;

  HotelService(this.supabase);

  Future<List<Hotel>> fetchHotels() async {
    try {
      final response = await supabase.from('hotels').select();
      debugPrint('Raw hotels response: $response');

      final data = (response as List<dynamic>?) ?? [];
      return data.map((json) => Hotel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching hotels: $e');
      return [];
    }
  }
}
