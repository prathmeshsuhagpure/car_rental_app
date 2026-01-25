import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesProvider with ChangeNotifier {
  final Set<String> _favoriteIds = {};
  String? _userId;

  Set<String> get favoriteIds => _favoriteIds;

  void setUser(String userId) {
    _userId = userId;
    restoreFavorites();
  }

  bool isFavorite(String carId) {
    return _favoriteIds.contains(carId);
  }

  Future<void> toggleFavorite(String carId) async {
    if (_userId == null) return;

    if (_favoriteIds.contains(carId)) {
      _favoriteIds.remove(carId);
    } else {
      _favoriteIds.add(carId);
    }

    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> restoreFavorites() async {
    if (_userId == null) return;

    final prefs = await SharedPreferences.getInstance();
    final ids =
        prefs.getStringList(_prefsKey(_userId!)) ?? <String>[];

    _favoriteIds
      ..clear()
      ..addAll(ids);

    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _prefsKey(_userId!),
      _favoriteIds.toList(),
    );
  }

  void clearSession() {
    _favoriteIds.clear();
    _userId = null;
    notifyListeners();
  }

  String _prefsKey(String userId) => 'favorite_car_ids_$userId';
}
