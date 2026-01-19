import 'package:flutter/material.dart';
import '../models/country_model.dart';

final List<CountryCode> countryCodes = [
  CountryCode(code: '+91', country: 'IND', flag: '🇮🇳'),
  CountryCode(code: '+1', country: 'USA', flag: '🇺🇸'),
  CountryCode(code: '+44', country: 'GBR', flag: '🇬🇧'),
  CountryCode(code: '+93', country: 'AFG', flag: '🇦🇫'),
  CountryCode(code: '+355', country: 'ALB', flag: '🇦🇱'),
  CountryCode(code: '+213', country: 'DZA', flag: '🇩🇿'),
  CountryCode(code: '+1684', country: 'ASM', flag: '🇦🇸'),
  CountryCode(code: '+376', country: 'AND', flag: '🇦🇩'),
  CountryCode(code: '+244', country: 'AGO', flag: '🇦🇴'),
  CountryCode(code: '+1264', country: 'AIA', flag: '🇦🇮'),
  CountryCode(code: '+672', country: 'ATA', flag: '🇦🇶'),
  CountryCode(code: '+1268', country: 'ATG', flag: '🇦🇬'),
  CountryCode(code: '+54', country: 'ARG', flag: '🇦🇷'),
  CountryCode(code: '+374', country: 'ARM', flag: '🇦🇲'),
  CountryCode(code: '+297', country: 'ABW', flag: '🇦🇼'),
  CountryCode(code: '+61', country: 'AUS', flag: '🇦🇺'),
  CountryCode(code: '+43', country: 'AUT', flag: '🇦🇹'),
  CountryCode(code: '+994', country: 'AZE', flag: '🇦🇿'),
];

List<String> locationSuggestions = [
  "Faras",
  "Dharampeth",
  "Buldi",
  "Railway Station",
  "Itwari",
  "Manish Nagar",
  "Mankapur",
  "Gorewada",
  "Koradi",
];

final List<String> cardImages = [
  'assets/images/debit card 1.webp',
  'assets/images/debit card 2.webp',
];

class LocationTimeData {
  final String location;
  final String shortLocation; // for display
  final DateTime startDateTime;
  final DateTime endDateTime;
  final int carCount;

  LocationTimeData({
    required this.location,
    required this.shortLocation,
    required this.startDateTime,
    required this.endDateTime,
    required this.carCount,
  });
}

// Helper method to format date and time
String formatDateTime(DateTime date, TimeOfDay time) {
  final months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];

  final month = months[date.month - 1];
  final day = date.day;
  final hour = time.hourOfPeriod;
  final period = time.period == DayPeriod.am ? 'AM' : 'PM';
  final displayHour = hour == 0 ? 12 : hour;

  return '$day $month|$displayHour$period';
}

final List<String> modelYear = [
  '2010',
  '2011',
  '2012',
  '2013',
  '2014',
  '2015',
  '2016',
  '2017',
  '2018',
  '2019',
  '2020',
  '2021',
  '2022',
  '2023',
  '2024',
  '2025',
];
final List<String> carBrands = [
  "Maruti Suzuki",
  "Tata Motors",
  "Mahindra",
  "Kia",
  "Hyundai",
  "Toyota",
  "Honda",
  "Volkswagen",
  "MG Motor",
  "Audi",
  "BMW",
  "Skoda",
  "Mercedes-Benz",
  "Lexus",
  "Jeep",
  "Land Rover",
  "Jaguar",
  "Volvo",
  "Porsche",
  "Lamborghini",
  "Ferrari",
  "Bentley",
  "Rolls-Royce",
  "Maserati",
  "Renault",
  "Nissan",
  "Citroen",
  "Ford",
  "BYD",
  "Isuzu"
];

Map<String, List<String>> carModelsByBrand = {
  'Toyota': ['Camry', 'Corolla', 'RAV4', 'Highlander', 'Tacoma'],
  'Maruti Suzuki': [
    'Swift',
    'Dzire',
    'Baleno',
    'Jimny',
    'Brezza',
    'Grand Vitara',
    'Alto',
    'Fronx',
    'Ertiga',
    "Celerio",
    'Ignis',
    'WagonR',
    'XL6',
    'Ciaz',
    'Invicto',
    'Eeco'
  ],
  'Tata Motors': [
    'Harrier',
    'Safari',
    'Altroz',
    'Curvv',
    'Nexon',
    'Zest',
    'Tigor',
    'Punch'
  ],
  'Mahindra': [
    'XUV 700',
    'Scorpio',
    'XUV 500',
    'XUV 300',
    'XUV 3XO',
    'Thar',
    'Roxx',
    'Scorpio N',
    'Bolero',
    'Bolero Neo',
    'Xev 9e',
    'Be 6'
  ],
  'Skoda': [
    "Favorit",
    "Felicia",
    "Citigo",
    "Fabia",
    "Fabia Combi",
    "Fabia Sedan",
    "Felicia Combi",
    "Octavia",
    "Octavia Combi",
    "Roomster",
    "Yeti",
    "Rapid",
    "Rapid Spaceback",
    "Superb",
    "Superb Combi"
  ],
  'MG Motor': ['Hector', 'Comet', 'EV 6'],
  'Honda': ['Civic', 'CR-V', 'Accord', 'Pilot', 'Odyssey'],
  'Ford': ['F-150', 'Escape', 'Explorer', 'Mustang', 'Bronco'],
  'BMW': ['3 Series', '5 Series', 'X3', 'X5', 'M3'],
  'Mercedes-Benz': ['C-Class', 'E-Class', 'GLC', 'GLE', 'S-Class'],
  'Audi': ['A3', 'A4', 'Q5', 'Q7', 'R8'],
  'Nissan': ['Altima', 'Rogue', 'Titan', 'Sentra', 'Pathfinder'],
  'Hyundai': ['Elantra', 'Tucson', 'Santa Fe', 'Sonata', 'Kona'],
  'Kia': ['Forte', 'Sportage', 'Telluride', 'Sorento', 'K5'],
  'Chevrolet': ['Silverado', 'Equinox', 'Malibu', 'Tahoe', 'Corvette'],
  'Volkswagen': ['Jetta', 'Tiguan', 'Passat', 'Atlas', 'Golf'],
  'Subaru': ['Outback', 'Forester', 'Crosstrek', 'Impreza', 'WRX'],
  'Mazda': ['CX-5', 'Mazda3', 'Mazda6', 'CX-9', 'MX-5 Miata'],
  'Tesla': ['Model 3', 'Model S', 'Model X', 'Model Y', 'Cybertruck'],
  'Porsche': ['911', 'Cayenne', 'Macan', 'Panamera', 'Taycan'],
  'Lexus': ['RX', 'ES', 'NX', 'IS', 'GX'],
  'Jeep': ['Wrangler', 'Grand Cherokee', 'Cherokee', 'Renegade', 'Gladiator'],
  'Volvo': ['XC60', 'S60', 'XC90', 'V60', 'S90'],
  'Land Rover': ['Range Rover', 'Discovery', 'Defender', 'Evoque', 'Velar'],
  'Jaguar': ['F-PACE', 'XE', 'XF', 'F-TYPE', 'E-PACE'],
};

final List<String> fuelTypes = [
  'Petrol',
  'Diesel',
  'Electric',
  'Hybrid',
  'CNG'
];
final List<String> transmissionTypes = ['Manual', 'Automatic'];
final List<String> bodyTypes = [
  'Sedan',
  'SUV',
  'Hatchback',
  'Coupe',
  'Convertible',
  'Wagon',
  'Pickup'
];
final List<String> colors = [
  'White',
  'Black',
  'Silver',
  'Gray',
  'Red',
  'Blue',
  'Green',
  'Yellow',
  'Orange',
  'Brown'
];
final List<String> availableFeatures = [
  'Air Conditioning',
  'GPS Navigation',
  'Bluetooth',
  'USB Charging',
  'Backup Camera',
  'Parking Sensors',
  'Sunroof',
  'Leather Seats',
  'Heated Seats',
  'Keyless Entry',
  'Push Start',
  'Cruise Control',
  'Lane Assist',
  'Blind Spot Monitor',
  'Premium Audio',
  'Wi-Fi Hotspot'
];
