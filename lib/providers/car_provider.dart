import 'package:flutter/foundation.dart';
import '../models/car_model.dart';
import '../services/api_service.dart';

class CarProvider with ChangeNotifier {
  List<Car> _cars = [];
  Car? _selectedCar;
  bool _isLoading = false;
  String? _error;

  List<Car> get cars => _cars;
  Car? get selectedCar => _selectedCar;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final ApiService _apiService = ApiService();

  Future<void> loadCars() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getCars(); // should return List<Car>
      _cars = response;
    } catch (e) {
      _error = 'Error getting cars: $e';
    }

    _isLoading = false;
    notifyListeners();
  }


  Future<void> getCarById(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedCar = await _apiService.getCarById(id);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  void setSelectedCar(Car car) {
    _selectedCar = car;
    notifyListeners();
  }

  void clearSelectedCar() {
    _selectedCar = null;
    notifyListeners();
  }

  List<Car> searchCars(String query) {
    if (query.isEmpty) {
      return _cars;
    }

    query = query.toLowerCase();
    return _cars.where((car) {
      return car.brand.toLowerCase().contains(query) ||
          car.model.toLowerCase().contains(query) ||
          car.category.toLowerCase().contains(query);
    }).toList();
  }

  List<Car> filterByAvailability(bool available) {
    return _cars.where((car) => car.availability == available).toList();
  }

  List<Car> filterByPriceRange(double minPrice, double maxPrice) {
    return _cars.where((car) =>
    car.pricePerDay >= minPrice && car.pricePerDay <= maxPrice
    ).toList();
  }

  List<Car> filterByCategory(String category) {
    if (category.isEmpty) {
      return _cars;
    }

    return _cars.where((car) =>
    car.category.toLowerCase() == category.toLowerCase()
    ).toList();
  }

  List<String> getAvailableCategories() {
    Set<String> categories = {};
    for (var car in _cars) {
      categories.add(car.category);
    }
    return categories.toList();
  }

  List<Car> getFeaturedCars() {
    if (_cars.isEmpty) {
      return [];
    }

    List<Car> availableCars = filterByAvailability(true);

    availableCars.sort((a, b) {
      return a.pricePerDay.compareTo(b.pricePerDay);
    });

    int featuredCount = availableCars.length > 5 ? 5 : availableCars.length;
    return availableCars.sublist(0, featuredCount);
  }
}