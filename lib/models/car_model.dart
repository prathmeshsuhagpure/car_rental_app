class Car {
  final String? id;
  final String brand;
  final String model;
  final int year;
  final String color;
  final String licensePlate;
  final double pricePerDay;
  final int seats;
  final String transmission;
  final String fuelType;
  final List<String> features;
  final List<String> images;
  final String location;
  final bool availability;
  final String? createdAt;
  final String? updatedAt;
  final String category;
  final double rating;
  final String? originalPrice;
  final String distance;
  final String hostedBy;
  final int reviews;
  final bool isFavorite;
  final bool isGuestFavorite;
  final bool hasActiveFastTag;
  final int? trips;
  final String? hostId;

  Car({
    this.id,
    required this.brand,
    required this.model,
    required this.year,
    required this.color,
    required this.licensePlate,
    required this.pricePerDay,
    required this.seats,
    required this.transmission,
    required this.fuelType,
    required this.features,
    required this.images,
    required this.location,
    required this.availability,
    required this.category,
    this.createdAt,
    this.updatedAt,
    this.trips,
    this.hostId,
    required this.rating,
    required this.originalPrice,
    required this.distance,
    required this.hostedBy,
    required this.reviews,
    required this.isFavorite,
    required this.isGuestFavorite,
    required this.hasActiveFastTag,
  });

  // Original fromJson method for API data
  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
        id: json['_id'] ?? '',
        brand: json['brand'] ?? '',
        model: json['model'] ?? '',
        year: json['year'] ?? 0,
        color: json['color'] ?? '',
        licensePlate: json['licensePlate'] ?? '',
        pricePerDay: (json['pricePerDay'] ?? 0).toDouble(),
        seats: json['seats'] ?? 0,
        transmission: json['transmission'] ?? '',
        fuelType: json['fuelType'] ?? '',
        features: List<String>.from(json['features'] ?? []),
        images: List<String>.from(json['images'] ?? []),
        location: json['location'] ?? '',
        availability: json['availability'] ?? false,
        category: json['category'] ?? '',
        createdAt: json['createdAt'],
        updatedAt: json['updatedAt'],
        trips: json['trips'],
        rating: (json['rating'] ?? 5).toDouble(),
        originalPrice: json['originalPrice'],
        distance: json['distance'] ?? '',
        hostedBy: json['hostedBy'] ?? "Company itself",
        reviews: (json['reviews'] ?? 0),
        isFavorite: json['isFavorite'] ?? false,
        isGuestFavorite: json['isGuestFavorite'] ?? false,
        hostId: json['hostId'] ?? "",
        hasActiveFastTag: json['hasActiveFastTag'] ?? false);
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'brand': brand,
      'model': model,
      'year': year,
      'color': color,
      'pricePerDay': pricePerDay,
      'licensePlate': licensePlate,
      'seats': seats,
      'transmission': transmission,
      'fuelType': fuelType,
      'features': features,
      'images': images,
      "location": location,
      "availability": availability,
      "category": category,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'trips': trips,
      'rating': rating,
      'originalPrice': originalPrice,
      'distance': distance,
      'hostedBy': hostedBy,
      'reviews': reviews,
      'isFavorite': isFavorite,
      'isGuestFavorite': isGuestFavorite,
      'hasActiveFastTag': hasActiveFastTag,
      'hostId' : hostId,
    };
  }

  String get title => "$brand $model $year";

  String get name => "$brand $model";

  String get subTitle => "$transmission $fuelType $seats";

  double get totalPrice => pricePerDay * 5;
}
