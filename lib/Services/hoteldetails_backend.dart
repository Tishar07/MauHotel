import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/hotel_model.dart';
import '../models/review_model.dart';

class HotelDetailsService {
  final SupabaseClient supabase = Supabase.instance.client;

  /// Fetch reviews for a specific hotel
  Future<List<Review>> fetchReviews(int hotelId) async {
    try {
      final response = await supabase
          .from('reviews')
          .select()
          .eq('hotel_id', hotelId)
          .order('review_date', ascending: false);
      if (response == null) return [];
      return (response as List).map((json) => Review.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching reviews: $e');
      return [];
    }
  }

  /// Fetch all hotels (used for comparison)
  Future<List<Hotel>> fetchAllHotels() async {
    try {
      final response = await supabase.from('hotels').select();
      if (response == null) return [];
      return (response as List).map((json) => Hotel.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching hotels: $e');
      return [];
    }
  }
}
