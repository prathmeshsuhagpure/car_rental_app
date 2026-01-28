import 'package:flutter/material.dart';

class CarRentalInfo {
  final String carId;
  final String carName;
  final String carModel;
  final String? carImage;
  final String rentalStatus; // 'active', 'upcoming', 'available'
  final String? renterName;
  final DateTime? rentalStartDate;
  final DateTime? rentalEndDate;

  CarRentalInfo({
    required this.carId,
    required this.carName,
    required this.carModel,
    this.carImage,
    required this.rentalStatus,
    this.renterName,
    this.rentalStartDate,
    this.rentalEndDate,
  });

  factory CarRentalInfo.fromJson(Map<String, dynamic> json) {
    return CarRentalInfo(
      carId: json['carId'].toString(),
      carName: json['carName'] ?? '',
      carModel: json['carModel'] ?? '',
      carImage: json['carImage'],
      rentalStatus: json['rentalStatus'] ?? 'available',
      renterName: json['renterName'],
      rentalStartDate: json['rentalStartDate'] != null
          ? DateTime.parse(json['rentalStartDate'])
          : null,
      rentalEndDate: json['rentalEndDate'] != null
          ? DateTime.parse(json['rentalEndDate'])
          : null,
    );
  }

  String get displayStatus {
    switch (rentalStatus) {
      case 'active':
        return 'Active Rental';
      case 'upcoming':
        return 'Upcoming Rental';
      case 'available':
        return 'Available';
      case 'maintenance':
        return 'Under Maintenance';
      default:
        return 'Unknown';
    }
  }

  Color get statusColor {
    switch (rentalStatus) {
      case 'active':
        return const Color(0xFF4CAF50);
      case 'upcoming':
        return const Color(0xFF2196F3);
      case 'available':
        return const Color(0xFF9E9E9E);
      case 'maintenance':
        return const Color(0xFFFF9800);
      default:
        return const Color(0xFF666666);
    }
  }

  IconData get statusIcon {
    switch (rentalStatus) {
      case 'active':
        return Icons.key;
      case 'upcoming':
        return Icons.calendar_today;
      case 'available':
        return Icons.check_circle_outline;
      case 'maintenance':
        return Icons.build_circle_outlined;
      default:
        return Icons.help_outline;
    }
  }
}
