class CarEarning {
  final String brand;
  final String model;
  final String? image;
  final int earnings;

  CarEarning({
    required this.brand,
    required this.model,
    required this.earnings,
    this.image,
  });

  factory CarEarning.fromJson(Map<String, dynamic> json) {
    return CarEarning(
      brand: json['brand'],
      model: json['model'],
      image: json['image'],
      earnings: json['earnings'],
    );
  }
}

class HostEarnings {
  final int totalEarnings;
  final List<CarEarning> cars;

  HostEarnings({
    required this.totalEarnings,
    required this.cars,
  });

  factory HostEarnings.fromJson(Map<String, dynamic> json) {
    return HostEarnings(
      totalEarnings: json['totalEarnings'] ?? 0,
      cars: (json['cars'] as List)
          .map((e) => CarEarning.fromJson(e))
          .toList(),
    );
  }
}
