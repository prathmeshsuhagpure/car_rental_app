import 'package:car_rent_app/models/user_model.dart';
import 'package:intl/intl.dart';
import 'car_model.dart';

class BookingModel {
  final String id;
  final String userId;
  final String carId;
  final Car? car;
  final User? user;
  final double amount;
  final String pickUpLocation;
  final String dropOffLocation;
  final DateTime startDate;
  final DateTime endDate;
  final String bookingStatus;
  final String paymentStatus;
  final String? paymentId;
  final String rentalStatus;
  final DateTime createdAt;

  BookingModel({
    required this.id,
    required this.userId,
    required this.carId,
    this.car,
    this.user,
    required this.amount,
    required this.pickUpLocation,
    required this.dropOffLocation,
    required this.startDate,
    required this.endDate,
    required this.bookingStatus,
    required this.paymentStatus,
    this.paymentId,
    required this.rentalStatus,
    required this.createdAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['_id']?.toString() ?? '',
      userId: json['user'] is Map
          ? json['user']['_id']?.toString() ?? ''
          : json['user']?.toString() ?? '',
      carId: json['carId']?.toString() ?? '',
      car: json['car'] != null && json['car'] is Map
          ? Car.fromJson(json['car'])
          : null,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      amount: (json['totalPrice'] ?? json['amount'] ?? 0).toDouble(),
      pickUpLocation: json['pickUpLocation']?.toString() ?? '',
      dropOffLocation: json['dropOffLocation']?.toString() ?? '',
      startDate: DateTime.tryParse(json['startDate'] ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['endDate'] ?? '') ?? DateTime.now(),
      bookingStatus: json['bookingStatus']?.toString() ?? 'pending',
      paymentStatus: json['paymentStatus']?.toString() ?? 'pending',
      paymentId: json['paymentId']?.toString(),
      rentalStatus: json['rentalStatus'] ?? 'completed',
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
      'rentalStatus': rentalStatus
    };
  }

  String get userName => user?.name ?? "User";

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
