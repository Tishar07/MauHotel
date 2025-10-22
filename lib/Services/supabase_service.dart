import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/hotel_model.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Hotel>> fetchHotels({
    String? location,
    String? sortBy,
    Map<String, String>? filters,
  }) async {
    try {
      // Start query
      final supabaseQuery = _client.from('hotels').select('*');

      // Apply location filter (returns PostgrestFilterBuilder)
      final filteredQuery = (location != null && location.isNotEmpty)
          ? supabaseQuery.ilike('location', '%$location%')
          : supabaseQuery;

      // Apply hotel_class filter
      final classFilteredQuery = (filters != null &&
              filters['hotel_class'] != null &&
              filters['hotel_class']!.isNotEmpty)
          ? filteredQuery.eq('category', '${filters['hotel_class']!}-Star')
          : filteredQuery;

      // Apply amenity filter
      final amenityFilteredQuery = (filters != null &&
              filters['amenity'] != null &&
              filters['amenity']!.isNotEmpty)
          ? classFilteredQuery.contains('amenities', [filters['amenity']!])
          : classFilteredQuery;

      // ------------------ Sorting ------------------
      PostgrestTransformBuilder? sortedQuery;
      switch (sortBy) {
        case 'price_low_to_high':
          sortedQuery = amenityFilteredQuery.order('price_per_night', ascending: true);
          break;
        case 'price_high_to_low':
          sortedQuery = amenityFilteredQuery.order('price_per_night', ascending: false);
          break;
        case 'rating_high_to_low':
          sortedQuery = amenityFilteredQuery.order('rating_avg', ascending: false);
          break;
        case 'most_reviewed':
          sortedQuery = amenityFilteredQuery.order('rooms_available', ascending: false);
          break;
        default:
          sortedQuery = amenityFilteredQuery; // keep as is
      }

      // Execute query
      final data = await sortedQuery;

      return (data as List).map((e) => Hotel.fromJson(e)).toList();
    } catch (e) {
      print('Error fetching hotels from Supabase: $e');
      return [];
    }
  }
  Future<Hotel> getHotelById(String id) async {
  try {
    final response = await _client
        .from('hotels')
        .select()
        .eq('id', id)
        .single();

    return Hotel.fromJson(response);
  } catch (e) {
    print('Error fetching hotel by ID: $e');
    throw Exception('Hotel not found');
  }
 }
}


