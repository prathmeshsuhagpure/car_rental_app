import 'dart:io';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

Future<Position> getCurrentLocation() async {
  final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw Exception('Location services are disabled');
  }

  LocationPermission permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      throw Exception('Location permission denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    throw Exception('Location permission permanently denied');
  }

  LocationSettings locationSettings;

  if (Platform.isAndroid) {
    locationSettings = AndroidSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 0,
      forceLocationManager: false,
    );
  } else if (Platform.isIOS || Platform.isMacOS) {
    locationSettings = AppleSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 0,
    );
  } else {
    locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 0,
    );
  }

  return await Geolocator.getCurrentPosition(
    locationSettings: locationSettings,
  );
}

Future<LatLngModel> getCarLocation(String address) async {
  final List<Location> locations = await locationFromAddress(address);

  if (locations.isEmpty) {
    throw Exception('Unable to find car location');
  }

  final Location location = locations.first;

  // Sanity check (still valid)
  if (location.latitude.abs() > 90 || location.longitude.abs() > 180) {
    throw Exception('Invalid coordinates returned');
  }

  return LatLngModel(
    latitude: location.latitude,
    longitude: location.longitude,
  );
}

double calculateDistanceInKm({
  required double startLat,
  required double startLng,
  required double endLat,
  required double endLng,
}) {
  final double distanceInMeters = Geolocator.distanceBetween(
    startLat,
    startLng,
    endLat,
    endLng,
  );

  return distanceInMeters / 1000;
}

class LatLngModel {
  final double latitude;
  final double longitude;

  const LatLngModel({
    required this.latitude,
    required this.longitude,
  });
}
