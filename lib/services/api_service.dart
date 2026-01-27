import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../models/booking_model.dart';
import '../models/car_model.dart';
import '../models/review_model.dart';
import '../models/user_model.dart';
import 'api_endpoints.dart';
import 'package:path/path.dart' as path;

class ApiService {
  final String? baseUrl = ApiConstants.baseUrl;
  final _secureStorage = const FlutterSecureStorage();

  String? _token;
  User? _cachedUserProfile;

  /*void clearToken() {
    _token = null;
    _cachedUserProfile = null;
  }*/

  void setToken(String? token) {
    _token = token;
    _cachedUserProfile = null;
  }

  Future<User?> getUserProfile({bool forceRefresh = false}) async {
    final headers = await getHeaders();
    if (forceRefresh) {
      _cachedUserProfile = null;
    }

    if (_cachedUserProfile != null) {
      return _cachedUserProfile;
    }

    try {
      // Make sure you're using the current token
      final response = await http.get(
        Uri.parse('$baseUrl${ApiConstants.getUserprofile}'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final user = User.fromJson(data['user'] ?? data);

        _cachedUserProfile = user;

        return user;
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching user profile : $e');
    }
  }

  Future<String?> getToken() async {
    if (_token != null) return _token;
    _token = await _secureStorage.read(key: 'auth_token');
    return _token;
  }

  Future<Map<String, String>> getHeaders() async {
    final token = await getToken();

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // Send OTP using Twilio backend
  Future<Map<String, dynamic>> sendOTP(String phoneNumber) async {
    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl${ApiConstants.sendOtp}'),
        headers: headers,
        body: jsonEncode({'phoneNumber': phoneNumber}),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'OTP sent successfully',
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to send OTP',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Resend OTP using Twilio backend
  Future<Map<String, dynamic>> resendOTP(String phoneNumber) async {
    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl${ApiConstants.resendOtp}'),
        headers: headers,
        body: jsonEncode({'phoneNumber': phoneNumber}),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'OTP resent successfully',
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to resend OTP',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Verify OTP using Twilio backend
  Future<Map<String, dynamic>> verifyOTP(
    String otp,
    String phoneNumber, {
    bool isHost = false,
  }) async {
    try {
      final headers = await getHeaders();
      final requestBody = {
        'otp': otp,
        'phoneNumber': phoneNumber,
        'isHost': isHost,
      };

      final response = await http.post(
        Uri.parse('$baseUrl${ApiConstants.verifyOtp}'),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (responseData['token'] != null) {
          _token = responseData['token'];
        }
        return {
          'success': true,
          'message': responseData['message'] ?? 'Login successful',
          'token': responseData['token'],
          'user': User.fromJson(responseData['user']),
          'isHost': responseData['isHost'] ?? isHost,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Invalid OTP',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> verifyUserAccount(
      String phoneNumber, String otp) async {
    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl${ApiConstants.verifyUserAccount}'),
        headers: headers,
        body: jsonEncode({
          'phoneNumber': phoneNumber,
          'otp': otp,
        }),
      );

      final data = jsonDecode(response.body);

      return {
        'success': response.statusCode == 200,
        'message': data['message'] ?? 'Account verified successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Verification failed: $e',
      };
    }
  }

  Future<List<Car>> getCars() async {
    final response = await http.get(Uri.parse('$baseUrl${ApiConstants.cars}'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['data'] is List) {
        return (data['data'] as List)
            .map((json) => Car.fromJson(json))
            .toList();
      } else {
        throw Exception('Unexpected response format: "data" is not a list');
      }
    } else {
      throw Exception('Failed to load cars: ${response.statusCode}');
    }
  }

  Future<Car> getCarById(String id) async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl${ApiConstants.getCar(id)}'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        return Car.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load car details');
      }
    } catch (e) {
      throw Exception('Error getting car details: $e');
    }
  }

  Future<Map<String, dynamic>> updateUserProfile(
      Map<String, dynamic> userData) async {
    try {
      final headers = await getHeaders();

      final response = await http.put(
        Uri.parse('$baseUrl${ApiConstants.updateProfile}'),
        headers: headers,
        body: jsonEncode(userData),
      );

      if (response.statusCode != 200) {
        return {
          'success': false,
          'message': 'Server responded with status code ${response.statusCode}',
        };
      }

      final responseData = jsonDecode(response.body);

      if (responseData is Map<String, dynamic> &&
          responseData['success'] == true &&
          responseData.containsKey('user')) {
        final userJson = responseData['user'];

        // Ensure the 'user' data is a valid map
        if (userJson is Map<String, dynamic>) {
          return {
            'success': true,
            'user': userJson,
          };
        } else {
          return {
            'success': false,
            'message': 'Invalid user data format from server.',
          };
        }
      }

      return {
        'success': false,
        'message': responseData['message'] ?? 'Profile update failed.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred while updating your profile.',
      };
    }
  }

  Future<Map<String, dynamic>> createBooking(BookingModel booking) async {
    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl${ApiConstants.bookings}'),
        headers: headers,
        body: jsonEncode(booking.toJson()),
      );

      Map<String, dynamic> decoded;
      try {
        final decodedResponse = jsonDecode(response.body);
        if (decodedResponse is Map<String, dynamic>) {
          decoded = decodedResponse;
        } else {
          return {
            'success': false,
            'message': 'Invalid response structure from server.',
          };
        }
      } catch (jsonError) {
        return {
          'success': false,
          'message': 'Failed to parse server response: ${jsonError.toString()}',
        };
      }

      // Check for successful status codes AND success flag
      if ((response.statusCode == 201 || response.statusCode == 200) &&
          decoded['success'] == true) {
        return decoded;
      } else {
        // Handle error responses
        final errorMessage = decoded['message'] ??
            'Unknown error occurred (Status: ${response.statusCode})';
        return {
          'success': false,
          'message': errorMessage,
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> cancelBooking(String bookingId) async {
    try {
      final headers = await getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl${ApiConstants.bookings}/$bookingId'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Booking cancelled successfully'};
      } else {
        return {
          'success': false,
          'message': jsonDecode(response.body)['message'] ??
              'Failed to cancel booking',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<List<BookingModel>> getUserBookings() async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl${ApiConstants.bookings}'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        // Try to detect the list from common keys
        List<dynamic> dataList;
        if (json is Map<String, dynamic>) {
          if (json['bookings'] is List) {
            dataList = json['bookings'];
          } else if (json['data'] is List) {
            dataList = json['data'];
          } else if (json['result'] is List) {
            dataList = json['result'];
          } else {
            throw Exception('No valid bookings list found in response');
          }
        } else {
          throw Exception('Expected JSON object but got ${json.runtimeType}');
        }

        return dataList
            .whereType<Map<String, dynamic>>()
            .map((booking) => BookingModel.fromJson(booking))
            .toList();
      } else {
        throw Exception('Failed to load bookings');
      }
    } catch (e) {
      throw Exception('Error getting bookings: $e');
    }
  }

  Future<Map<String, dynamic>> uploadImages({
    required List<File> imageFiles,
    required String userId,
  }) async {
    try {
      final token = await getToken();
      final uri = Uri.parse('$baseUrl${ApiConstants.uploadProfilePic}/$userId');

      final request = http.MultipartRequest('POST', uri);

      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Mapping images to appropriate field names
      List<String> fieldNames = [
        "profilePicture",
        "driverLicense",
        "identityProof"
      ];

      for (int i = 0; i < imageFiles.length; i++) {
        if (i < fieldNames.length) {
          request.files.add(
            await http.MultipartFile.fromPath(
              fieldNames[i], // Assign correct field name
              imageFiles[i].path,
              filename: path.basename(imageFiles[i].path),
            ),
          );
        }
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final decoded = jsonDecode(responseBody);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': decoded['message'],
          'uploadedFiles': decoded['uploadedFiles'],
        };
      } else {
        return {
          'success': false,
          'message': decoded['message'] ?? 'Upload failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Upload failed: $e',
      };
    }
  }

  Future<Map<String, dynamic>> logout() async {
    try {
      if (_token != null && _token!.isNotEmpty) {
        await http.post(
          Uri.parse('$baseUrl/logout'),
          headers: {
            'Authorization': 'Bearer $_token',
            'Content-Type': 'application/json',
          },
        );
      }
    } catch (e) {
      debugPrint("Logout API failed: $e");
      // Do NOT throw — logout must continue locally
    } finally {
      // Only clear API-level memory
      _token = null;
    }

    return {'success': true};
  }

  /*Future<Car> createCar(Car car) async {
    try {
      final carJson = car.toJson();
      carJson.remove('_id'); // Remove MongoDB _id field
      carJson.remove('id');
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl${ApiConstants.listCar}'),
        headers: headers,
        body: jsonEncode(car.toJson()),
      );

      if (response.statusCode == 201) {
        // Car created successfully
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return Car.fromJson(responseData['data']);
      } else {
        // Handle errors based on your backend's response format
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        throw Exception(
            'Failed to create car: ${errorData['message'] ?? response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }*/

  Future<void> sendFCMTokenToBackend(String token) async {
    try {
      final headers = await getHeaders();

      await http.post(
        Uri.parse('$baseUrl${ApiConstants.saveFcmToken}'),
        headers: headers,
        body: jsonEncode({"fcmToken": token}),
      );
    } catch (e) {
      debugPrint('❌ Error sending FCM token: $e');
    }
  }

// Sign up with email and password
  Future<Map<String, dynamic>?> signupWithEmail({
    required String name,
    required String email,
    required String password,
    required bool isHost,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl${ApiConstants.signup}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
          'isHost': isHost,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'token': data['token'],
          'isHost': data['isHost'] ?? isHost,
          'message': data['message'] ?? 'Signup successful',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Signup failed',
        };
      }
    } catch (e) {
      debugPrint('Error in signupWithEmail: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Login with email and password
  Future<Map<String, dynamic>?> loginWithEmail({
    required String email,
    required String password,
    required bool isHost,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl${ApiConstants.login}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': email,
          'password': password,
          'isHost': isHost,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'token': data['token'],
          'isHost': data['isHost'] ?? isHost,
          'message': data['message'] ?? 'Login successful',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Login failed',
        };
      }
    } catch (e) {
      debugPrint('Error in loginWithEmail: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  Future<Car> createCarWithMap(
      Map<String, dynamic> carData, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl${ApiConstants.listCar}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Add the auth token
        },
        body: jsonEncode(carData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        // Handle different response structures
        if (responseData['success'] == true && responseData['car'] != null) {
          return Car.fromJson(responseData['car']);
        } else if (responseData['data'] != null) {
          return Car.fromJson(responseData['data']);
        } else {
          return Car.fromJson(responseData);
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
            'Failed to create car: ${errorData['message'] ?? errorData['error'] ?? 'Unknown error'}');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }

  Future<void> submitReview(ReviewModel review, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl${ApiConstants.submitReview}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(review.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception(
        'Failed to submit review: ${response.body}',
      );
    }
  }

  Future<List<ReviewModel>> fetchReviews(String carId) async {
    final response = await http.get(
      Uri.parse('$baseUrl${ApiConstants.fetchReviews}/$carId'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load reviews: ${response.body}',
      );
    }

    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => ReviewModel.fromJson(json)).toList();
  }

  Future<Map<String, dynamic>> fetchHostDashboard(String token) async {
    final response = await http.get(
      Uri.parse("$baseUrl${ApiConstants.hostDashboard}"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load dashboard");
    }
  }
}
