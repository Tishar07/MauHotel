import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/hotel_model.dart';
import '../models/review_model.dart';

class HotelService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Fetch all hotels
  Future<List<Hotel>> fetchHotels({
    String? category,
    String? amenity,
    String? search,
    String? sort,
  }) async {
    dynamic query = _client.from('hotels').select();

    if (category != null && category.isNotEmpty)
      query = query.eq('category', category);
    if (amenity != null && amenity.isNotEmpty)
      query = query.contains('amenities', [amenity]);
    if (search != null && search.isNotEmpty)
      query = query.ilike('name', '%$search%');

    switch (sort) {
      case 'price_low_to_high':
        query = query.order('price_per_night');
        break;
      case 'price_high_to_low':
        query = query.order('price_per_night', ascending: false);
        break;
      case 'rating_high_to_low':
        query = query.order('rating_avg', ascending: false);
        break;
      case 'rating_low_to_high':
        query = query.order('rating_avg');
        break;
    }

    final data = await query;
    return (data as List).map((json) => Hotel.fromJson(json)).toList();
  }

  /// Fetch reviews for a specific hotel
  Future<List<Review>> fetchReviews(int hotelId) async {
    try {
      final response = await _client
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
}
