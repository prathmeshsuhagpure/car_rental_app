import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static final String baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost';
  //static String get baseUrl => dotenv.env['https://car-rent-server.netlify.app/.netlify/functions/index'] ??'http://172.16.99.202:5000';

  // Auth endpoints
  static const getUserprofile = '/api/auth/get-user-profile';
  static const updateProfile = '/api/auth/update-profile';
  static const sendOtp = '/api/auth/send-otp';
  static const resendOtp = '/api/auth/resend-otp';
  static const verifyOtp = '/api/auth/verify-otp';
  static const verifyUserAccount = '/api/auth/verify-user-account';
  static const uploadProfilePic = '/api/auth/upload-user-images';
  static const signup = '/api/auth/signup';
  static const login = '/api/auth/login';


  //Save FCM Token End Point
  static const saveFcmToken = '/api/auth/save-fcm-token';

  // Get Profile Image End Point
  String imageUrl = '$baseUrl/';

  // Payments
  static const createPayment ='/api/payments/createPayment';

  // Car endpoints
  static const cars = '/api/cars';
  static String getCar(String id) => '$baseUrl/cars/$id';
  static const listCar = '/api/cars';

  // Booking endpoints
  static const bookings = '/api/bookings';
  static String getBooking(String id) => '$baseUrl/bookings/$id';
  static String cancelBooking(String id) => '$baseUrl/bookings/$id/cancel';
  static const allBookings = '/api/bookings/all';
}
