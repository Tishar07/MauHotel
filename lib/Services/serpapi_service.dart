import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/hotel_model.dart';

class SerpApiService {
  final String apiKey = '4c070bb676cd781d2fe522303df7cffe7fe980637552629de069c59bfacb08d5';

  Future<List<Hotel>> fetchHotels({
    String location = 'Mauritius',
    String checkIn = '2025-10-20',
    String checkOut = '2025-10-25',
  }) async {
    final uri = Uri.parse(
      'https://serpapi.com/search.json'
      '?engine=google_hotels'
      '&q=$location'
      '&check_in_date=$checkIn'
      '&check_out_date=$checkOut'
      '&api_key=$apiKey',
    );

    final response = await http.get(uri);

    debugPrint('Request URL: $uri');
    debugPrint('Status: ${response.statusCode}');
    debugPrint('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['properties'] as List? ?? [];
      return results.map((json) => Hotel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load hotels: ${response.statusCode}');
    }
  }
}
