class ReviewModel {
  final String carId;
  final String userId;
  final double rating;
  final String comment;

  ReviewModel({
    required this.carId,
    required this.userId,
    required this.rating,
    required this.comment,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      carId: json['carId'] is Map
          ? json['carId']['_id']
          : json['carId'],
      userId: json['userId'] is Map
          ? json['userId']['_id']
          : json['userId'],
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'carId': carId,
      'userId': userId,
      'rating': rating,
      'comment': comment,
    };
  }
}
