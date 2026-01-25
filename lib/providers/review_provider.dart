import 'package:flutter/material.dart';
import '../models/review_model.dart';
import '../services/api_service.dart';

class ReviewProvider extends ChangeNotifier {
  ApiService? apiService;

  ReviewProvider(this.apiService);

  final List<ReviewModel> _reviews = [];
  bool _isLoading = false;
  String? _error;

  List<ReviewModel> get reviews => List.unmodifiable(_reviews);
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> fetchReviews(String carId) async {
    if (apiService == null) {
      _error = 'ApiService not initialized';
      notifyListeners();
      return;
    }

    _setLoading(true);
    _error = null;

    try {
      final result = await apiService!.fetchReviews(carId);
      _reviews
        ..clear()
        ..addAll(result);
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> submitReview(
      ReviewModel review,
      String token,
      ) async {
    if (apiService == null) {
      throw Exception('ApiService not initialized');
    }

    _setLoading(true);
    _error = null;

    try {
      await apiService!.submitReview(review, token);
      await fetchReviews(review.carId); // refresh
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void clear() {
    _reviews.clear();
    _error = null;
    notifyListeners();
  }
}
