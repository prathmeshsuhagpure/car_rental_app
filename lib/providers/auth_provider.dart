import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  User? _user;
  String? _error;
  String? _token;
  bool _isLoading = false;
  bool _isHost = false; // Add this line

  final ApiService _apiService = ApiService();

  static const String TOKEN_KEY = 'auth_token';
  static const String PHONE_KEY = 'user_phone';
  static const String LOGIN_KEY = 'isLoggedIn';
  static const String USER_KEY = 'user';
  static const String HOST_KEY = 'isHost';

  User? get user => _user;
  String? get error => _error;
  bool get isLoading => _isLoading;
  bool get isHost => _isHost; // Add this getter

  Future<void> _saveUserToStorage(User user) async {
    try {
      await _secureStorage.write(
        key: USER_KEY,
        value: json.encode(user.toJson()),
      );
    } catch (e) {
      _error = 'Failed to save user data';
    }
  }

  // Helper method to clear all user data
  Future<void> _clearAllData() async {
    try {
      // Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(TOKEN_KEY);
      await prefs.remove(LOGIN_KEY);
      await prefs.remove(PHONE_KEY);
      await prefs.remove(HOST_KEY); // Add this line

      // Clear FlutterSecureStorage
      await _secureStorage.delete(key: TOKEN_KEY);
      await _secureStorage.delete(key: USER_KEY);

      // Clear in-memory data
      _user = null;
      _token = null;
      _error = null;
      _isHost = false; // Add this line
    } catch (e) {
      debugPrint("Error clearing data: $e");
    }
  }

  // Send OTP using Twilio backend
  Future<Map<String, dynamic>> sendOtpLogin(String fullPhone) async {
    _error = null;
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _apiService.sendOTP(fullPhone);

      _isLoading = false;
      notifyListeners();

      if (result['success'] == true) {
        return {'success': true, 'message': result['message']};
      } else {
        _error = result['message'] ?? 'Failed to send OTP';
        return {'success': false, 'message': _error!};
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': _error!};
    }
  }

  /*Future<Map<String, dynamic>> sendOtpLogin(String fullPhone) async {
    _error = null;
    notifyListeners();

    try {
      final result = await _apiService.sendOTP(fullPhone);

      if (result['success'] == true) {
        // Don't save phone number yet, wait for successful verification
        return {'success': true, 'message': result['message']};
      } else {
        _error = result['message'] ?? 'Login failed';
        notifyListeners();
        return {'success': false, 'message': _error};
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return {'success': false, 'message': _error};
    }
  }*/

  // Resend OTP using Twilio backend
  Future<Map<String, dynamic>> resendOtpLogin(String fullPhone) async {
    _error = null;
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _apiService.resendOTP(fullPhone);

      _isLoading = false;
      notifyListeners();

      if (result['success'] == true) {
        return {'success': true, 'message': result['message']};
      } else {
        _error = result['message'] ?? 'Resend OTP failed';
        return {'success': false, 'message': _error!};
      }
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return {'success': false, 'message': _error!};
    }
  }


  /*Future<Map<String, dynamic>> resendOtpLogin(String fullPhone) async {
    _error = null;
    _isLoading = true;
    notifyListeners();

    try {
      final result = await resendOtpLogin(fullPhone); // call Firebase resend method

      _isLoading = false;
      notifyListeners();

      if (result['success'] == true) {
        return {'success': true, 'message': result['message']};
      } else {
        _error = result['message'] ?? 'Resend OTP failed';
        return {'success': false, 'message': _error!};
      }
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return {'success': false, 'message': _error!};
    }
  }*/

  // Verify OTP and login using Twilio backend
  Future<Map<String, dynamic>> verifyOtpAndLogin(
      String otp,
      String phoneNumber, {
        bool isHost = false
      }) async {
    _error = null;
    _setLoading(true);

    try {
      await _clearAllData();
      notifyListeners();

      final response = await _apiService.verifyOTP(otp, phoneNumber, isHost: isHost);

      if (response == null || response['success'] != true) {
        _error = response['message'] ?? 'OTP verification failed';
        print("response: ${response['message']}");
        _setLoading(false);
        return {'success': false, 'message': _error!};
      }

      print("token: ${response['token']}");
      _token = response['token'];
      if (_token == null) {
        _error = 'No token received';
        _setLoading(false);
        return {'success': false, 'message': _error!};
      }

      // Set host status
      _isHost = response['isHost'] ?? isHost;

      // Save token, login state, and host status
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(LOGIN_KEY, true);
      await prefs.setString(TOKEN_KEY, _token!);
      await prefs.setString(PHONE_KEY, phoneNumber);
      await prefs.setBool(HOST_KEY, _isHost);

      // Save to secure storage
      await _secureStorage.write(key: TOKEN_KEY, value: _token!);
      _apiService.setToken(_token!);

      // Fetch fresh user profile for the new user
      final userProfile = await _apiService.getUserProfile();
      if (userProfile != null) {
        _user = userProfile;
        await _saveUserToStorage(userProfile);
        debugPrint(
            "New ${_isHost ? 'host' : 'user'} logged in: ${_user?.name} - ${_user?.phoneNumber}");
      } else {
        // If we can't get user profile, clear everything and fail
        await _clearAllData();
        _error = 'Failed to fetch user profile';
        _setLoading(false);
        return {'success': false, 'message': _error!};
      }

      _setLoading(false);
      notifyListeners();
      return {
        'success': true,
        'message': response['message'] ?? 'Login successful',
        'isHost': _isHost
      };
    } catch (e) {
      _error = e.toString();
      await _clearAllData();
      _setLoading(false);
      notifyListeners();
      return {'success': false, 'message': _error!};
    }
  }

  // Modified method to include isHost parameter
  /*Future<Map<String, dynamic>> verifyOtpAndLogin(String otp, String phoneNumber,
      {bool isHost = false}) async {
    _error = null;
    _setLoading(true);

    try {
      await _clearAllData();
      notifyListeners();

      final response =
          await _apiService.verifyOTP(otp, phoneNumber, isHost: isHost);

      if (response == null || response['success'] != true) {
        _error = response['message'] ?? 'OTP verification failed';
        print("response: ${response['message']}");
        _setLoading(false);
        return {'success': false, 'message': _error!};
      }

      print("token: ${response['token']}");
      _token = response['token'];
      if (_token == null) {
        _error = 'No token received';
        _setLoading(false);
        return {'success': false, 'message': _error!};
      }

      // Set host status
      _isHost = response['isHost'] ?? isHost;

      // Save token, login state, and host status
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(LOGIN_KEY, true);
      await prefs.setString(TOKEN_KEY, _token!);
      await prefs.setString(PHONE_KEY, phoneNumber);
      await prefs.setBool(HOST_KEY, _isHost); // Add this line

      // Save to secure storage
      await _secureStorage.write(key: TOKEN_KEY, value: _token!);

      // Fetch fresh user profile for the new user
      final userProfile = await _apiService.getUserProfile();
      if (userProfile != null) {
        _user = userProfile;
        await _saveUserToStorage(userProfile);
        debugPrint(
            "🟢 New ${_isHost ? 'host' : 'user'} logged in: ${_user?.name} - ${_user?.phoneNumber}");
      } else {
        // If we can't get user profile, clear everything and fail
        await _clearAllData();
        _error = 'Failed to fetch user profile';
        _setLoading(false);
        return {'success': false, 'message': _error!};
      }

      _setLoading(false);
      notifyListeners();
      return {
        'success': true,
        'message': response['message'] ?? 'Login successful',
        'isHost': _isHost //
      };
    } catch (e) {
      _error = e.toString();
      await _clearAllData();
      _setLoading(false);
      notifyListeners();
      return {'success': false, 'message': _error!};
    }
  }*/

  Future<bool> tryAutoLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString(TOKEN_KEY);

      // Fallback to secure storage if not in prefs
      _token ??= await _secureStorage.read(key: TOKEN_KEY);

      final isLoggedIn = prefs.getBool(LOGIN_KEY) ?? false;
      _isHost = prefs.getBool(HOST_KEY) ?? false; // Add this line

      debugPrint("🟡 isLoggedIn: $isLoggedIn");
      debugPrint("🟡 isHost: $_isHost"); // Add this line
      debugPrint("🟡 token in autoLogin: $_token");

      if (!isLoggedIn || _token == null) {
        // Clear any residual data
        await _clearAllData();
        return false;
      }

      _apiService.setToken(_token!);

      // Try to fetch fresh user profile
      final userProfile = await _apiService.getUserProfile();
      debugPrint("🟢 userProfile retrieved: ${userProfile?.name}");

      if (userProfile != null) {
        _user = userProfile;
        await _saveUserToStorage(userProfile);
        debugPrint(
            "🟢 Auto-login successful for ${_isHost ? 'host' : 'user'}: ${_user?.name}");
        notifyListeners();
        return true;
      } else {
        // If can't fetch profile, clear everything
        debugPrint("🔴 Failed to fetch user profile during auto-login");
        await _clearAllData();
        return false;
      }
    } catch (e) {
      debugPrint("🔴 Error in tryAutoLogin: $e");
      _error = e.toString();
      await _clearAllData();
      return false;
    }
  }

  Future<bool> logout() async {
    _setLoading(true);
    try {
      // Call API logout
      await _apiService.logout();

      // Clear all data
      await _clearAllData();

      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Error during logout: $e");
      // Even if API call fails, clear local data
      await _clearAllData();
      _setLoading(false);
      notifyListeners();
      return true; // Return true because we cleared local data
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> userData) async {
    _error = null;
    _setLoading(true);

    try {
      final result = await _apiService.updateUserProfile(userData);

      if (result['success']) {
        final updatedUser = User.fromJson(result['user']);
        _user = updatedUser;
        await _saveUserToStorage(updatedUser);
        notifyListeners();
        _setLoading(false);
        return true;
      } else {
        _error = result['message'];
        notifyListeners();
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      _setLoading(false);
      return false;
    }
  }

  Future<Map<String, dynamic>> verifyUserProfile(String phoneNumber, String otp) async {
    _error = null;
    _setLoading(true);

    try {
      final response = await _apiService.verifyUserAccount(phoneNumber, otp);

      if (response['success'] == true) {
        // Optionally update the local user object if you track isVerified
        if (_user != null) {
          _user = _user!.copyWith(isVerified: true);
          await _saveUserToStorage(_user!);
        }

        _setLoading(false);
        notifyListeners();
        return {
          'success': true,
          'message': response['message'] ?? 'User account verified'
        };
      } else {
        _error = response['message'] ?? 'Failed to verify user account';
        _setLoading(false);
        notifyListeners();
        return {'success': false, 'message': _error!};
      }
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      return {'success': false, 'message': _error!};
    }
  }


  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Add this method to force clear all data (useful for debugging)
  Future<void> forceLogout() async {
    await _clearAllData();
    notifyListeners();
  }
}
