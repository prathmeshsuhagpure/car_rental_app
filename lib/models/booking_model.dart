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

  // CopyWith method for creating modified copies
  BookingModel copyWith({
    String? id,
    String? userId,
    String? carId,
    Car? car,
    User? user,
    double? amount,
    String? pickUpLocation,
    String? dropOffLocation,
    DateTime? startDate,
    DateTime? endDate,
    String? bookingStatus,
    String? paymentStatus,
    String? paymentId,
    String? rentalStatus,
    DateTime? createdAt,
  }) {
    return BookingModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      carId: carId ?? this.carId,
      car: car ?? this.car,
      user: user ?? this.user,
      amount: amount ?? this.amount,
      pickUpLocation: pickUpLocation ?? this.pickUpLocation,
      dropOffLocation: dropOffLocation ?? this.dropOffLocation,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      bookingStatus: bookingStatus ?? this.bookingStatus,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentId: paymentId ?? this.paymentId,
      rentalStatus: rentalStatus ?? this.rentalStatus,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    final dynamic carData = json['carId'];
    final dynamic userData = json['userId'];

    return BookingModel(
      id: json['_id']?.toString() ?? '',

      // ✅ User ID
      userId: userData is Map
          ? userData['_id']?.toString() ?? ''
          : userData?.toString() ?? '',

      // ✅ Car ID
      carId: carData is Map
          ? carData['_id']?.toString() ?? ''
          : carData?.toString() ?? '',

      // ✅ Car object (only if populated)
      car: carData is Map<String, dynamic>
          ? Car.fromJson(carData)
          : null,

      // ✅ User object (only if populated)
      user: userData is Map<String, dynamic>
          ? User.fromJson(userData)
          : null,

      // ✅ Amount (safe for int / double / string)
      amount: (json['totalPrice'] ?? json['amount'] ?? 0) is num
          ? (json['totalPrice'] ?? json['amount']).toDouble()
          : double.tryParse(
          (json['totalPrice'] ?? json['amount']).toString()) ??
          0.0,

      pickUpLocation: json['pickUpLocation']?.toString() ?? '',
      dropOffLocation: json['dropOffLocation']?.toString() ?? '',

      // ✅ Dates (no silent logic bugs)
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),

      bookingStatus: json['bookingStatus']?.toString() ?? 'pending',
      paymentStatus: json['paymentStatus']?.toString() ?? 'pending',
      paymentId: json['paymentId']?.toString(),
      rentalStatus: json['rentalStatus']?.toString() ?? 'upcoming',

      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }


  /*factory BookingModel.fromJson(Map<String, dynamic> json) {
    final dynamic carData = json['carId'];
    final dynamic userData = json['userId'];

    return BookingModel(
      id: json['_id']?.toString() ?? '',
      *//*userId: json['user'] is Map
          ? json['user']['_id']?.toString() ?? ''
          : json['user']?.toString() ?? '',*//*
      userId: userData is Map
          ? userData['_id']?.toString() ?? ''
          : userData?.toString() ?? '',
      carId: carData is Map
          ? carData['_id']?.toString() ?? ''
          : carData?.toString() ?? '',
      *//*car: carData is Map
          ? Car.fromJson(Map<String, dynamic>.from(carData))
          : null,*//*
      car: json['carId'] != null
          ? Car.fromJson(json['carId'])
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
  }*/

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

  @override
  String toString() {
    return 'BookingModel(id: $id, carId: $carId, amount: $amount, bookingStatus: $bookingStatus, paymentStatus: $paymentStatus)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BookingModel &&
        other.id == id &&
        other.userId == userId &&
        other.carId == carId &&
        other.amount == amount &&
        other.bookingStatus == bookingStatus &&
        other.paymentStatus == paymentStatus;
  }

  @override
  int get hashCode {
    return id.hashCode ^
    userId.hashCode ^
    carId.hashCode ^
    amount.hashCode ^
    bookingStatus.hashCode ^
    paymentStatus.hashCode;
  }
}