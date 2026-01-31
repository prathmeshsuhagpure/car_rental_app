import '../models/host_dashboard_model.dart';
import '../services/api_service.dart';
import 'package:flutter/material.dart';

class HostDashboardProvider with ChangeNotifier {
  bool isLoading = false;
  String? error;

  int totalCars = 0;
  int activeRentals = 0;
  double monthlyEarnings = 0;


  List<Map<String, String>> recentActivities = [];
  List<CarRentalInfo> cars = [];

  final ApiService _apiService = ApiService();

  // Get only active or upcoming rentals
  List<CarRentalInfo> get activeOrUpcomingCars {
    return cars
        .where((car) =>
            car.rentalStatus == 'active' || car.rentalStatus == 'upcoming')
        .toList();
  }

  // Check if host has only one car
  bool get hasSingleCar => totalCars == 1;

  // Get the single car info (if exists)
  CarRentalInfo? get singleCarInfo =>
      hasSingleCar && cars.isNotEmpty ? cars.first : null;

  Future<void> fetchDashboardData(String token) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final data = await _apiService.fetchHostDashboard(token);

      totalCars = data["totalCars"];
      activeRentals = data["activeRentals"];
      monthlyEarnings = data["monthlyEarnings"].toDouble();
      print(data.toString());

      // Parse car rental information
      if (data['cars'] != null && data['cars'] is List) {
        cars = (data['cars'] as List)
            .map((carJson) => CarRentalInfo.fromJson(carJson))
            .toList();
      } else {
        cars = [];
      }

      recentActivities = data['recentActivities'] != null
          ? List<Map<String, String>>.from(
              data["recentActivities"].map((item) => {
                    "title": item["title"].toString(),
                    "subtitle": item["subtitle"].toString(),
                  }),
            )
          : [];
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
