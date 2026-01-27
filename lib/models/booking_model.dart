/*
import 'package:intl/intl.dart';
import 'car_model.dart';

class BookingModel {
  final String id;
  final String userId;
  final String carId;
  final String carName;
  final double amount;
  final String pickUpLocation;
  final String dropOffLocation;
  final DateTime startDate;
  final DateTime endDate;
  final double rating;
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
    required this.pickUpLocation,
    required this.dropOffLocation,
    required this.startDate,
    required this.endDate,
    required this.rating,
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
      pickUpLocation: json['pickupLocation']?.toString() ?? '',
      dropOffLocation: json['dropoffLocation']?.toString() ?? '',
      startDate: DateTime.tryParse(json['startDate']?.toString() ?? '') ??
          DateTime.now(),
      endDate: DateTime.tryParse(json['endDate']?.toString() ?? '') ??
          DateTime.now(),
      rating: (json['rating'] ?? 0).toDouble(),
      paymentStatus: json['paymentStatus']?.toString() ?? 'pending',
      bookingStatus: json['bookingStatus']?.toString() ?? 'pending',
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
      car: json['car'],
      */
/*user: json['user'] is Map ? Map<String, dynamic>.from(json['user']) : null,*//*

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
      'pickupLocation': pickUpLocation,
      'dropoffLocation': dropOffLocation,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'rating': rating,
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
*/

import 'package:intl/intl.dart';
import 'car_model.dart';

class BookingModel {
  final String id;
  final String userId;
  final String carId;
  final Car? car;
  final double amount;
  final String pickUpLocation;
  final String dropOffLocation;
  final DateTime startDate;
  final DateTime endDate;
  final String bookingStatus;
  final String paymentStatus;
  final String? paymentId;
  final DateTime createdAt;

  BookingModel({
    required this.id,
    required this.userId,
    required this.carId,
    this.car,
    required this.amount,
    required this.pickUpLocation,
    required this.dropOffLocation,
    required this.startDate,
    required this.endDate,
    required this.bookingStatus,
    required this.paymentStatus,
    this.paymentId,
    required this.createdAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['_id']?.toString() ?? '',
      userId: json['user'] is Map
          ? json['user']['_id']?.toString() ?? ''
          : json['user']?.toString() ?? '',
      carId: json['carId']?.toString() ?? '',
      car: json['carId'] != null && json['carId'] is Map
          ? Car.fromJson(json['carId'])
          : null,
      amount: (json['totalPrice'] ?? json['amount'] ?? 0).toDouble(),
      pickUpLocation: json['pickUpLocation']?.toString() ?? '',
      dropOffLocation: json['dropOffLocation']?.toString() ?? '',
      startDate: DateTime.tryParse(json['startDate'] ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['endDate'] ?? '') ?? DateTime.now(),
      bookingStatus: json['bookingStatus']?.toString() ?? 'pending',
      paymentStatus: json['paymentStatus']?.toString() ?? 'pending',
      paymentId: json['paymentId']?.toString(),
      createdAt:
      DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user': userId,
      'carId': carId,
      'amount': amount,
      'pickUpLocation': pickUpLocation,
      'dropOffLocation': dropOffLocation,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'bookingStatus': bookingStatus,
      'paymentStatus': paymentStatus,
      'paymentId': paymentId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  int get durationInDays => endDate.difference(startDate).inDays + 1;

  String get formattedStartDate =>
      DateFormat('MMM dd, yyyy').format(startDate);

  String get formattedEndDate =>
      DateFormat('MMM dd, yyyy').format(endDate);

  bool get isActive => bookingStatus == 'active';
  bool get isCompleted => bookingStatus == 'completed';
  bool get isCancelled => bookingStatus == 'cancelled';
  bool get isPending => bookingStatus == 'pending';

  bool get isPaid => paymentStatus == 'completed';
  bool get isPaymentPending => paymentStatus == 'pending';
  bool get isPaymentFailed => paymentStatus == 'failed';
}
