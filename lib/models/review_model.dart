class Review {
  final int id;
  final int hotelId;
  final int rating;
  final String comment;
  final String reviewDate;
  final String userId;

  Review({
    required this.id,
    required this.hotelId,
    required this.rating,
    required this.comment,
    required this.reviewDate,
    required this.userId,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] ?? 0,
      hotelId: json['hotel_id'],
      rating: json['rating'],
      comment: json['comment'] ?? '',
      reviewDate: json['review_date'] ?? '',
      userId: json['user_id'] ?? '',
    );
  }
}
