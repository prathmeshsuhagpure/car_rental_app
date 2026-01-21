/*
class User {
  final String id;
  final String? name;
  final String? email;
  final String phoneNumber;
  final String role;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isVerified;
  final String? profilePicture;
  final String? driverLicenseNumber;
  final String? driverLicenseUrl;
  final String? aadharCardNumber;
  final String? aadharCardUrl;
  final DateTime? dateOfBirth;
  final String? gender;

  User({
    required this.id,
    this.name,
    this.email,
    required this.phoneNumber,
    this.role = 'user',
    this.createdAt,
    this.updatedAt,
    this.isVerified = false,
    this.profilePicture,
    this.driverLicenseNumber,
    this.driverLicenseUrl,
    this.aadharCardNumber,
    this.aadharCardUrl,
    this.dateOfBirth,
    this.gender,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? 'unknown-id',
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phoneNumber'] ?? json['phone'] ?? '',
      role: json['role'] ?? 'user',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
      isVerified: json['isVerified'] ?? json['verified'] ?? false,
      profilePicture: json['profilePicture'] ?? json['avatar'],
      driverLicenseNumber: json['driverLicenseNumber'],
      driverLicenseUrl: json['driverLicenseUrl'],
      aadharCardNumber: json['aadharCardNumber'],
      aadharCardUrl: json['aadharCardUrl'],
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.tryParse(json['dateOfBirth'])
          : null,
      gender: json['gender'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isVerified': isVerified,
      'profilePicture': profilePicture,
      'driverLicenseNumber': driverLicenseNumber,
      'driverLicenseUrl': driverLicenseUrl,
      'aadharCardNumber': aadharCardNumber,
      'aadharCardUrl': aadharCardUrl,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? role, // ✅ FIXED: Made nullable so it can be updated
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isVerified,
    String? profilePicture,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      // ✅ Now properly updates role
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isVerified: isVerified ?? this.isVerified,
      profilePicture: profilePicture ?? this.profilePicture,
      driverLicenseNumber: driverLicenseNumber,
      driverLicenseUrl: driverLicenseUrl,
    );
  }

  bool get isAdmin => role.toLowerCase() == 'admin';

  bool get isUser => role.toLowerCase() == 'user';

  bool get isHost => role.toLowerCase() == 'host'; // ✅ ADDED: Host role check

  String get displayName => (name?.isNotEmpty ?? false) ? name! : phoneNumber;

  String get formattedPhone {
    if (phoneNumber.length >= 10) {
      if (phoneNumber.startsWith('+')) {
        return phoneNumber;
      }
      return '+91 ${phoneNumber.substring(0, 5)} ${phoneNumber.substring(5)}';
    }
    return phoneNumber;
  }

  @override
  String toString() {
    return 'User{id: $id, name: $name, email: $email, phoneNumber: $phoneNumber, role: $role, isVerified: $isVerified}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is User &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.phoneNumber == phoneNumber &&
        other.role == role &&
        other.isVerified == isVerified;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        email.hashCode ^
        phoneNumber.hashCode ^
        role.hashCode ^
        isVerified.hashCode;
  }
}
*/
class User {
  final String id;
  final String? name;
  final String? email;
  final String? phoneNumber; // Changed to nullable since email users might not have phone
  final String role;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isVerified;
  final String? profilePicture;
  final String? driverLicenseNumber;
  final String? driverLicenseUrl;
  final String? aadharCardNumber;
  final String? aadharCardUrl;
  final DateTime? dateOfBirth;
  final String? gender;

  User({
    required this.id,
    this.name,
    this.email,
    this.phoneNumber, // Now nullable
    this.role = 'user',
    this.createdAt,
    this.updatedAt,
    this.isVerified = false,
    this.profilePicture,
    this.driverLicenseNumber,
    this.driverLicenseUrl,
    this.aadharCardNumber,
    this.aadharCardUrl,
    this.dateOfBirth,
    this.gender,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? 'unknown-id',
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phoneNumber'] ?? json['phone'],
      role: json['role'] ?? 'user',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
      isVerified: json['isVerified'] ?? json['verified'] ?? false,
      profilePicture: json['profilePicture'] ?? json['avatar'],
      driverLicenseNumber: json['driverLicenseNumber'],
      driverLicenseUrl: json['driverLicenseUrl'],
      aadharCardNumber: json['aadharCardNumber'],
      aadharCardUrl: json['aadharCardUrl'],
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.tryParse(json['dateOfBirth'])
          : null,
      gender: json['gender'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isVerified': isVerified,
      'profilePicture': profilePicture,
      'driverLicenseNumber': driverLicenseNumber,
      'driverLicenseUrl': driverLicenseUrl,
      'aadharCardNumber': aadharCardNumber,
      'aadharCardUrl': aadharCardUrl,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isVerified,
    String? profilePicture,
    String? driverLicenseNumber,
    String? driverLicenseUrl,
    String? aadharCardNumber,
    String? aadharCardUrl,
    DateTime? dateOfBirth,
    String? gender,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isVerified: isVerified ?? this.isVerified,
      profilePicture: profilePicture ?? this.profilePicture,
      driverLicenseNumber: driverLicenseNumber ?? this.driverLicenseNumber,
      driverLicenseUrl: driverLicenseUrl ?? this.driverLicenseUrl,
      aadharCardNumber: aadharCardNumber ?? this.aadharCardNumber,
      aadharCardUrl: aadharCardUrl ?? this.aadharCardUrl,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
    );
  }

  bool get isAdmin => role.toLowerCase() == 'admin';

  bool get isUser => role.toLowerCase() == 'user';

  bool get isHost => role.toLowerCase() == 'host';

  // Updated to prioritize name, then email, then phone
  String get displayName {
    if (name?.isNotEmpty ?? false) return name!;
    if (email?.isNotEmpty ?? false) return email!;
    if (phoneNumber?.isNotEmpty ?? false) return phoneNumber!;
    return 'User';
  }

  // Add a getter to identify the primary contact method
  String get primaryContact {
    if (email?.isNotEmpty ?? false) return email!;
    if (phoneNumber?.isNotEmpty ?? false) return phoneNumber!;
    return 'No contact info';
  }

  // Check if user has email
  bool get hasEmail => email?.isNotEmpty ?? false;

  // Check if user has phone
  bool get hasPhone => phoneNumber?.isNotEmpty ?? false;

  String get formattedPhone {
    if (phoneNumber == null || phoneNumber!.isEmpty) return 'No phone';

    if (phoneNumber!.length >= 10) {
      if (phoneNumber!.startsWith('+')) {
        return phoneNumber!;
      }
      return '+91 ${phoneNumber!.substring(0, 5)} ${phoneNumber!.substring(5)}';
    }
    return phoneNumber!;
  }

  @override
  String toString() {
    return 'User{id: $id, name: $name, email: $email, phoneNumber: $phoneNumber, role: $role, isVerified: $isVerified}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is User &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.phoneNumber == phoneNumber &&
        other.role == role &&
        other.isVerified == isVerified;
  }

  @override
  int get hashCode {
    return id.hashCode ^
    name.hashCode ^
    email.hashCode ^
    phoneNumber.hashCode ^
    role.hashCode ^
    isVerified.hashCode;
  }
}