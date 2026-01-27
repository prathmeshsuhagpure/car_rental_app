import 'package:flutter/foundation.dart';
import '../models/booking_model.dart';
import '../services/api_service.dart';

class BookingProvider with ChangeNotifier {
  List<BookingModel> _bookings = [];
  bool _isLoading = false;
  String? _error;

  final ApiService _apiService = ApiService();

  List<BookingModel> get bookings => _bookings;

  bool get isLoading => _isLoading;

  String? get error => _error;

  Future<void> loadUserBookings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // This already returns List<BookingModel>
      final bookings = await _apiService.getUserBookings();
      _bookings = bookings;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading bookings: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>> createBooking(BookingModel booking) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    Map<String, dynamic> result;

    try {
      result = await _apiService.createBooking(booking);

      if (result['success'] == true) {
        final newBooking = BookingModel.fromJson(result['data']);
        _bookings.add(newBooking);
      } else {
        _error = result['message'] ?? 'An unknown error occurred';
      }
    } catch (e) {
      result = {
        'success': false,
        'message': e.toString(),
      };
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
    return result;
  }

  Future<bool> cancelBooking(String bookingId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _apiService.cancelBooking(bookingId);

      if (result['success']) {
        _bookings.removeWhere((booking) => booking.id == bookingId);
        return true;
      } else {
        _error = result['message'];
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<BookingModel> getActiveBookings() {
    final now = DateTime.now();
    return _bookings
        .where((booking) =>
            booking.endDate.isAfter(now) &&
            booking.bookingStatus != 'cancelled')
        .toList();
  }

  List<BookingModel> getPastBookings() {
    final now = DateTime.now();
    return _bookings
        .where((booking) =>
            booking.endDate.isBefore(now) ||
            booking.bookingStatus == 'cancelled')
        .toList();
  }

  bool hasActiveBookingForCar(String carId) {
    final now = DateTime.now();
    return _bookings.any((booking) =>
        booking.carId == carId &&
        booking.endDate.isAfter(now) &&
        booking.bookingStatus != 'cancelled');
  }

  double getTotalSpent() {
    return _bookings.fold(
        0.0,
        (total, booking) => booking.bookingStatus != 'cancelled'
            ? total + booking.amount
            : total);
  }
}
