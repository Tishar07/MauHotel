class Hotel {
  final String name;
  final String imageUrl;
  final double rating;
  final int reviews;
  final String description;
  final String offer;
  final String price;

  Hotel({
    required this.name,
    required this.imageUrl,
    required this.rating,
    required this.reviews,
    required this.description,
    required this.offer,
    required this.price,
  });

  factory Hotel.fromJson(Map<String, dynamic> json) {
    return Hotel(
      name: json['name'] ?? 'No name',
      imageUrl: json['thumbnail'] ?? '', // or json['image_url']
      rating: (json['rating'] ?? 0).toDouble(),
      reviews: json['reviews'] ?? 0,
      description: json['description'] ?? 'No description',
      offer: json['offer'] ?? 'No offer',
      price: json['price'] ?? 'No price',
    );
  }
}
