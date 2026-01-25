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
  bool _isHost = false;
  bool isLoggingOut = false;

  final ApiService _apiService = ApiService();

  static const String TOKEN_KEY = 'auth_token';
  static const String PHONE_KEY = 'user_phone';
  static const String LOGIN_KEY = 'isLoggedIn';
  static const String USER_KEY = 'user';
  static const String HOST_KEY = 'isHost';

  User? get user => _user;
  String? get token => _token;

  String? get error => _error;

  bool get isLoading => _isLoading;

  bool get isHost => _isHost;

  void setVerified(bool value) {
    if (user == null) return;
    _user = user!.copyWith(isVerified: value);
    notifyListeners();
  }

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

  Future<void> _clearAllData() async {
    _user = null;
    _token = null;
    _isHost = false;

    _apiService.setToken(null); // 🔥 MOST IMPORTANT

    final prefs = await SharedPreferences.getInstance();
    //await prefs.clear();
    await prefs.remove('auth_token');
    await prefs.remove('refresh_token');
    await prefs.remove('is_host');
    await prefs.remove('user_id');

    await _secureStorage.deleteAll();
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

  // Verify OTP and login using Twilio backend
  Future<Map<String, dynamic>> verifyOtpAndLogin(String otp, String phoneNumber,
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
        _setLoading(false);
        return {'success': false, 'message': _error!};
      }

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

  // NEW: Sign up with email and password
  Future<Map<String, dynamic>> signupWithEmail(
    String name,
    String email,
    String password,
    bool isHost,
  ) async {
    _error = null;
    _setLoading(true);

    try {
      await _clearAllData();
      notifyListeners();

      final response = await _apiService.signupWithEmail(
        name: name,
        email: email,
        password: password,
        isHost: isHost,
      );

      if (response == null || response['success'] != true) {
        _error = response?['message'] ?? 'Signup failed';
        _setLoading(false);
        return {'success': false, 'message': _error!};
      }

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
      await prefs.setBool(HOST_KEY, _isHost);

      // Save to secure storage
      await _secureStorage.write(key: TOKEN_KEY, value: _token!);
      _apiService.setToken(_token!);

      // Fetch user profile
      final userProfile = await _apiService.getUserProfile(forceRefresh: true);
      if (userProfile != null) {
        _user = userProfile;
        await _saveUserToStorage(userProfile);
        debugPrint(
            "New ${_isHost ? 'host' : 'user'} signed up: ${_user?.name} - ${_user?.email}");
      } else {
        await _clearAllData();
        _error = 'Failed to fetch user profile';
        _setLoading(false);
        return {'success': false, 'message': _error!};
      }

      _setLoading(false);
      notifyListeners();
      return {
        'success': true,
        'message': response['message'] ?? 'Signup successful',
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

  // NEW: Login with email and password
  Future<Map<String, dynamic>> loginWithEmail(
    String email,
    String password,
    bool isHost,
  ) async {
    _error = null;
    _setLoading(true);

    try {
      await _clearAllData();
      notifyListeners();

      final response = await _apiService.loginWithEmail(
        email: email,
        password: password,
        isHost: isHost,
      );

      if (response == null || response['success'] != true) {
        _error = response?['message'] ?? 'Login failed';
        _setLoading(false);
        return {'success': false, 'message': _error!};
      }

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
      await prefs.setBool(HOST_KEY, _isHost);

      // Save to secure storage
      await _secureStorage.write(key: TOKEN_KEY, value: _token!);
      _apiService.setToken(_token!);

      // Fetch user profile
      final userProfile = await _apiService.getUserProfile();
      if (userProfile != null) {
        _user = userProfile;
        await _saveUserToStorage(userProfile);
        debugPrint(
            "${_isHost ? 'Host' : 'User'} logged in: ${_user?.name} - ${_user?.email}");
      } else {
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

  Future<bool> tryAutoLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString(TOKEN_KEY);

      _token ??= await _secureStorage.read(key: TOKEN_KEY);

      final isLoggedIn = prefs.getBool(LOGIN_KEY) ?? false;
      _isHost = prefs.getBool(HOST_KEY) ?? false;

      if (!isLoggedIn || _token == null) {
        await _clearAllData();
        return false;
      }

      _apiService.setToken(_token!);

      final userProfile = await _apiService.getUserProfile();

      if (userProfile != null) {
        _user = userProfile;
        await _saveUserToStorage(userProfile);
        notifyListeners();
        return true;
      } else {
        await _clearAllData();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      await _clearAllData();
      return false;
    }
  }

  Future<bool> logout() async {
    isLoggingOut = true;
    notifyListeners();

    try {
      await _apiService.logout();
    } catch (e) {
      debugPrint("API logout error (ignored): $e");
    }

    await _clearAllData();

    isLoggingOut = false;
    notifyListeners();

    return true;
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

  Future<Map<String, dynamic>> verifyUserProfile(
      String phoneNumber, String otp) async {
    _error = null;
    _setLoading(true);

    try {
      final response = await _apiService.verifyUserAccount(phoneNumber, otp);

      if (response['success'] == true) {
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

  Future<void> forceLogout() async {
    await _clearAllData();
    notifyListeners();
  }
}
