import 'dayplan_model.dart';

class Trip {
  final int? tripId;
  final String tripName;
  final String description;
  final DateTime dateFrom;
  final DateTime dateTo;
  final int hotelId;
  final List<DayPlan> itinerary;

  Trip({
    this.tripId,
    required this.tripName,
    required this.description,
    required this.dateFrom,
    required this.dateTo,
    required this.hotelId,
    required this.itinerary,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      tripId: json['trip_id'],
      tripName: json['trip_name'] ?? '',
      description: json['description'] ?? '',
      dateFrom: DateTime.parse(json['date_from']),
      dateTo: DateTime.parse(json['date_to']),
      hotelId: json['hotel_id'],
      itinerary:
          (json['itinerary'] as List<dynamic>?)
              ?.map((e) => DayPlan.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trip_name': tripName,
      'description': description,
      'date_from': dateFrom.toIso8601String(),
      'date_to': dateTo.toIso8601String(),
      'hotel_id': hotelId,
      'itinerary': itinerary.map((e) => e.toJson()).toList(),
    };
  }
}
