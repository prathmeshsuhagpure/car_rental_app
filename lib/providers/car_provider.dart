import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import '../models/car_model.dart';
import '../services/api_service.dart';
import 'favourites_provider.dart';
import 'package:provider/provider.dart';

class CarProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Car> _allCars = [];
  List<Car> _cars = [];
  Car? _selectedCar;

  bool _isLoading = false;
  String? _error;

  String _selectedCity = '';

  // GETTERS
  List<Car> get cars => _cars;
  Car? get selectedCar => _selectedCar;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedCity => _selectedCity;


  void attachDistancesToCars({
    required List<Car> cars,
    required double userLat,
    required double userLng,
  }) {
    for (final car in cars) {
      final meters = Geolocator.distanceBetween(
        userLat,
        userLng,
        car.latitude,
        car.longitude,
      );

      car.distanceKm = meters / 1000; // meters → km
    }
  }

  Future<void> loadCars(BuildContext context) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final favProvider = context.read<FavoritesProvider>();

    try {
      // 1️⃣ Ensure location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }

      // 2️⃣ Get user location
      final userPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // 3️⃣ Fetch cars from API
      final response = await _apiService.getCars();

      // 4️⃣ Attach distance to EACH car (IMPORTANT FIX)
      attachDistancesToCars(
        cars: response, // ✅ correct list
        userLat: userPosition.latitude,
        userLng: userPosition.longitude,
      );

      // 5️⃣ Store cars
      _allCars = response;
      _cars = List.from(_allCars);

      // 6️⃣ Restore favorites
      await favProvider.restoreFavorites();

      // 7️⃣ Apply city filter AFTER everything
      _applyCityFilter();
    } catch (e) {
      _error = 'Error getting cars: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  void setCity(String city) {
    _selectedCity = city;
    _applyCityFilter();
    notifyListeners();
  }

  void _applyCityFilter() {
    if (_selectedCity.isEmpty) {
      _cars = _allCars;
    } else {
      _cars = _allCars.where((car) {
        return car.location.address.toLowerCase() ==
            _selectedCity.toLowerCase();
      }).toList();
    }
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
    if (query.isEmpty) return _cars;

    query = query.toLowerCase();
    return _cars.where((car) {
      return car.brand.toLowerCase().contains(query) ||
          car.model.toLowerCase().contains(query) ||
          car.category.toLowerCase().contains(query);
    }).toList();
  }

  List<Car> filterByAvailability(bool available) {
    return _cars.where((car) => car.isAvailable == available).toList();
  }

  List<Car> filterByPriceRange(double minPrice, double maxPrice) {
    return _cars.where((car) =>
    car.originalPrice >= minPrice &&
        car.originalPrice <= maxPrice
    ).toList();
  }

  List<Car> filterByCategory(String category) {
    if (category.isEmpty) return _cars;

    return _cars.where((car) =>
    car.category.toLowerCase() ==
        category.toLowerCase()
    ).toList();
  }

  List<String> getAvailableCategories() {
    return _cars
        .map((car) => car.category)
        .toSet()
        .toList();
  }

  List<Car> getFeaturedCars() {
    final availableCars = filterByAvailability(true);

    availableCars.sort(
          (a, b) => a.originalPrice.compareTo(b.originalPrice),
    );

    return availableCars.take(5).toList();
  }
}
