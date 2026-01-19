import 'package:intl/intl.dart';
import 'car_model.dart';

class BookingModel {
  final String id;
  final String userId;
  final String carId;
  final String carName;
  final double amount;
  final String pickupLocation;
  final String dropoffLocation;
  final DateTime startDate;
  final DateTime endDate;
  final double rating;
  final int trips;
  final String paymentStatus;
  final String bookingStatus;
  final String bookingId;
  final String? createdAt;
  final String? updatedAt;
  final String status;
  final DateTime bookingDate;
  final String? paymentId;
  final Car? car;
  final Map<String, dynamic>? user;

  BookingModel({
    required this.id,
    required this.userId,
    required this.carId,
    required this.carName,
    required this.amount,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.startDate,
    required this.endDate,
    required this.rating,
    required this.trips,
    required this.paymentStatus,
    required this.bookingStatus,
    this.createdAt,
    this.updatedAt,
    this.car,
    this.user,
    required this.status,
    required this.bookingDate,
    this.paymentId,
  }) : bookingId = "BK${DateTime.now().millisecondsSinceEpoch}";

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['_id']?.toString() ?? '',
      userId: json['user'] is Map
          ? json['user']['_id']?.toString() ?? ''
          : json['user']?.toString() ?? json['userId']?.toString() ?? '',
      carId: json['carId'],
      carName: json['carName'],
      amount: (json['totalPrice'] ?? json['amount'] ?? 0).toDouble(),
      pickupLocation: json['pickupLocation']?.toString() ?? '',
      dropoffLocation: json['dropoffLocation']?.toString() ?? '',
      startDate: DateTime.tryParse(json['startDate']?.toString() ?? '') ??
          DateTime.now(),
      endDate: DateTime.tryParse(json['endDate']?.toString() ?? '') ??
          DateTime.now(),
      rating: (json['rating'] ?? 0).toDouble(),
      trips: json['trips'] ?? 0,
      paymentStatus: json['paymentStatus']?.toString() ?? 'pending',
      bookingStatus: json['bookingStatus']?.toString() ?? 'pending',
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
      car: json['car'],
      /*user: json['user'] is Map ? Map<String, dynamic>.from(json['user']) : null,*/
      status: json['status']?.toString() ?? 'active',
      bookingDate: DateTime.tryParse(json['bookingDate']?.toString() ?? '') ??
          DateTime.now(),
      paymentId: json['paymentId']?.toString(),
    );
  }


  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user': userId,
      'carId': carId,
      'carName': carName,
      'amount': amount,
      'pickupLocation': pickupLocation,
      'dropoffLocation': dropoffLocation,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'rating': rating,
      'trips': trips,
      'paymentStatus': paymentStatus,
      'bookingStatus': bookingStatus,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'status': status,
      'bookingDate': bookingDate.toIso8601String(),
      'paymentId': paymentId,
      "car" : car,
    };
  }

  // Formatted Dates
  String get formattedStartDate => DateFormat('MMM dd, yyyy').format(startDate);
  String get formattedEndDate => DateFormat('MMM dd, yyyy').format(endDate);
  String get formattedBookingDate => DateFormat('MMM dd, yyyy').format(bookingDate);

  int get durationInDays {
    return endDate.difference(startDate).inDays + 1;
  }

  // Status Check Helpers
  bool get isActive => bookingStatus == 'active';
  bool get isCompleted => bookingStatus == 'completed';
  bool get isCancelled => bookingStatus == 'cancelled';
  bool get isPending => bookingStatus == 'pending';
  bool get isPaid => paymentStatus == 'completed';
  bool get isPaymentPending => paymentStatus == 'pending';
  bool get isPaymentFailed => paymentStatus == 'failed';

  // Payment ID Helper
  bool get hasPaymentId => paymentId != null && paymentId!.isNotEmpty;
}
