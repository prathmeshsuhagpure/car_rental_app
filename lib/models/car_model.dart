class CarLocation {
  final double latitude;
  final double longitude;
  final String address;


  CarLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  factory CarLocation.fromJson(Map<String, dynamic> json) {
    final coordinates = json['coordinates'];

    return CarLocation(
      latitude: (coordinates[1] as num).toDouble(), // lat
      longitude: (coordinates[0] as num).toDouble(), // lng
      address: json['address'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': 'Point',
      'coordinates': [longitude, latitude],
      'address': address,
    };
  }

  String get state {
    final parts = address.split(',');
    if (parts.length < 2) return '';
    return parts[parts.length - 3].trim();
  }

  String get pincode {
    final match = RegExp(r'\b\d{6}\b').firstMatch(address);
    return match?.group(0) ?? '';
  }

  String get stateWithPincode => '$state - $pincode';
}

class Car {
  final String id;
  final String brand;
  final String model;
  final int year;
  final String licensePlate;
  final String fuelType;
  final String transmission;
  final String category;
  final String color;
  final int seats;
  final double average;
  final bool hasActiveFastTag;
  final List<String> features;
  final double originalPrice;
  final CarLocation location;
  final String description;
  final bool instantBooking;
  final bool isAvailable;
  final List<String> images;
  final String hostedBy;
  final String? hostId;
  final String? createdAt;
  final String? updatedAt;
  final double rating;
  final int reviews;

  double? distanceKm;

  Car({
    required this.id,
    required this.brand,
    required this.model,
    required this.year,
    required this.color,
    required this.licensePlate,
    required this.seats,
    required this.transmission,
    required this.fuelType,
    required this.features,
    required this.images,
    required this.location,
    required this.category,
    this.createdAt,
    this.updatedAt,
    this.hostId,
    required this.rating,
    required this.originalPrice,
    required this.hostedBy,
    required this.reviews,
    required this.hasActiveFastTag,
    required this.average,
    required this.description,
    required this.instantBooking,
    required this.isAvailable,
    this.distanceKm,
  });

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      id: json['_id'] ?? '',
      brand: json['brand'] ?? '',
      model: json['model'] ?? '',
      year: json['year'] ?? 0,
      licensePlate: json['licensePlate'] ?? '',
      fuelType: json['fuelType'] ?? '',
      transmission: json['transmission'] ?? '',
      category: json['category'] ?? '',
      color: json['color'] ?? '',
      seats: json['seats'] ?? 0,
      average: (json['average'] ?? 0).toDouble(),
      hasActiveFastTag: json['hasActiveFastTag'] ?? false,
      features: List<String>.from(json['features'] ?? []),
      originalPrice: (json['originalPrice'] ?? 0).toDouble(),
      location: CarLocation.fromJson(json['location'] ?? {}),
      description: json['description'] ?? '',
      instantBooking: json['instantBooking'] ?? false,
      isAvailable: json['isAvailable'] ?? true,
      images: List<String>.from(json['images'] ?? []),
      hostedBy: json['hostedBy'] ?? 'Company itself',
      hostId: json['hostId'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      rating: (json['rating'] ?? 0).toDouble(),
      reviews: json['reviews'] ?? 0,
    );
  }

  // ---------- Derived values ----------

  double get latitude => location.latitude;
  double get longitude => location.longitude;

  String get title => "$brand $model $year";
  String get name => "$brand $model";

  double get offerPrice => originalPrice * 0.8;

  String get formattedDistance {
    if (distanceKm == null) return '';

    if (distanceKm! < 1) {
      return '${(distanceKm! * 1000).round()} m';
    } else if (distanceKm! < 10) {
      return '${distanceKm!.toStringAsFixed(1)} km';
    } else {
      return '${distanceKm!.round()} km';
    }
  }
}
