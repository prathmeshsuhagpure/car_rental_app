import 'package:flutter/material.dart';
import '../services/api_service.dart';

class HostDashboardProvider with ChangeNotifier {
  bool isLoading = false;
  String? error;

  int totalCars = 0;
  int activeRentals = 0;
  double monthlyEarnings = 0;
  double rating = 0;

  List<Map<String, String>> recentActivities = [];

  final ApiService _apiService = ApiService();

  Future<void> fetchDashboardData(String token) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final data = await _apiService.fetchHostDashboard(token);

      totalCars = data["totalCars"];
      activeRentals = data["activeRentals"];
      monthlyEarnings = data["monthlyEarnings"].toDouble();
      rating = data["rating"].toDouble();

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
