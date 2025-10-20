class Hotel {
  final int hotelId;
  final String name;
  final String location;
  final String type;
  final String description;
  final double pricePerNight;
  final String currency;
  final String category;
  final String imageUrl;
  final List<String> amenities;
  final String availableFrom;
  final String availableTo;
  final int roomsAvailable;
  final double ratingAvg;

  Hotel({
    required this.hotelId,
    required this.name,
    required this.location,
    required this.type,
    required this.description,
    required this.pricePerNight,
    required this.currency,
    required this.category,
    required this.imageUrl,
    required this.amenities,
    required this.availableFrom,
    required this.availableTo,
    required this.roomsAvailable,
    required this.ratingAvg,
  });

  factory Hotel.fromJson(Map<String, dynamic> json) {
    return Hotel(
      hotelId: json['hotel_id'],
      name: json['name'] ?? 'Unknown Hotel',
      location: json['location'] ?? '',
      type: json['type'] ?? '',
      description: json['description'] ?? '',
      pricePerNight: (json['price_per_night'] is num)
          ? json['price_per_night'].toDouble()
          : 0.0,
      currency: json['currency'] ?? 'MUR',
      category: json['category'] ?? '',
      imageUrl: json['image_url'] ??
          'https://via.placeholder.com/150',
      amenities: (json['amenities'] as List?)?.map((e) => e.toString()).toList() ?? [],
      availableFrom: json['available_from'] ?? '',
      availableTo: json['available_to'] ?? '',
      roomsAvailable: json['rooms_available'] ?? 0,
      ratingAvg: (json['rating_avg'] is num)
          ? json['rating_avg'].toDouble()
          : 0.0,
    );
  }
}
