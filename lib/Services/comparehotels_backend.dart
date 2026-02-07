import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/hotel_model.dart';
import '../models/review_model.dart';

class CompareHotelsService {
  final SupabaseClient supabase = Supabase.instance.client;

  /* =======================
     HOTELS
  ======================== */

  /// Fetch all hotels
  Future<List<Hotel>> fetchAllHotels() async {
    try {
      final response = await supabase.from('hotels').select();

      if (response == null) return [];

      return (response as List).map((json) => Hotel.fromJson(json)).toList();
    } catch (e, st) {
      print('Error fetching hotels: $e\n$st');
      return [];
    }
  }

  /* =======================
     REVIEWS
  ======================== */

  /// Fetch all reviews for a hotel
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

  /// Get review count using existing fetchReviews
  Future<int> fetchReviewCount(int hotelId) async {
    final reviews = await fetchReviews(hotelId);
    return reviews.length;
  }

  /* =======================
     SIMILARITY LOGIC
  ======================== */

  /// Normalize amenities so variants match
  String _normalizeAmenity(String amenity) {
    final a = amenity.toLowerCase();

    if (a.contains('wifi')) return 'wifi';
    if (a.contains('pool')) return 'pool';
    if (a.contains('restaurant')) return 'restaurant';
    if (a.contains('bar')) return 'bar';
    if (a.contains('beach')) return 'beach';
    if (a.contains('yoga')) return 'yoga';

    return a;
  }

  /// Find similar hotels based on amenities & price
  List<Hotel> getSimilarHotels(
    Hotel baseHotel,
    List<Hotel> hotels, {
    int maxResults = 3,
    double priceRange = 5000,
  }) {
    final baseAmenities = baseHotel.amenities
        .map((e) => _normalizeAmenity(e))
        .toSet();

    final basePrice = baseHotel.pricePerNight;

    final List<_ScoredHotel> scoredHotels = [];

    for (final hotel in hotels) {
      if (hotel.hotelId == baseHotel.hotelId) continue;

      // Amenity similarity (Jaccard)
      final hotelAmenities = hotel.amenities
          .map((e) => _normalizeAmenity(e))
          .toSet();

      final intersection = baseAmenities.intersection(hotelAmenities).length;
      final union = baseAmenities.union(hotelAmenities).length;

      final amenityScore = union == 0 ? 0 : intersection / union;

      // Price similarity
      final priceDifference = (hotel.pricePerNight - basePrice).abs();

      final priceScore = priceDifference >= priceRange
          ? 0
          : 1 - (priceDifference / priceRange);

      // Final score
      final totalScore = (amenityScore * 0.6) + (priceScore * 0.4);

      scoredHotels.add(_ScoredHotel(hotel, totalScore));
    }

    scoredHotels.sort((a, b) => b.score.compareTo(a.score));

    return scoredHotels.take(maxResults).map((e) => e.hotel).toList();
  }
}

/* =======================
   INTERNAL MODEL
======================== */

class _ScoredHotel {
  final Hotel hotel;
  final double score;

  _ScoredHotel(this.hotel, this.score);
}
