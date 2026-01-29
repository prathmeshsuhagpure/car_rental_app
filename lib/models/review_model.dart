class ReviewModel {
  final String carId;
  final String userId;
  final int rating;
  final String comment;
  final String userName;

  ReviewModel({
    required this.carId,
    required this.userId,
    required this.rating,
    required this.comment,
    required this.userName,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      carId: json['carId'] is Map ? json['carId']['_id'] : json['carId'],
      userId: json['userId'] is Map ? json['userId']['_id'] : json['userId'],
      userName: json['userName'] ?? '',
      rating: json['rating'] ?? 0,
      comment: json['comment'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'carId': carId,
      'userId': userId,
      'rating': rating,
      'comment': comment,
      'userName': userName,
    };
  }
}
