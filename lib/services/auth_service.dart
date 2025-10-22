import 'dart:convert';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../models/user.dart';

class AuthService {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  // Demo credentials
  static const Map<String, String> _demoCredentials = {
    'demo': 'demo123',
    'user': 'password',
    'admin': 'admin123',
    'test': 'test123',
  };

  // Generate mock JWT token
  String _generateJWTToken(User user) {
    final header = {
      'alg': 'HS256',
      'typ': 'JWT',
    };

    final now = DateTime.now();
    final expiry = now.add(const Duration(hours: 24)); // Token expires in 24 hours

    final payload = {
      'sub': user.id.toString(),
      'username': user.username,
      'email': user.email,
      'fullName': user.fullName,
      'iat': now.millisecondsSinceEpoch ~/ 1000,
      'exp': expiry.millisecondsSinceEpoch ~/ 1000,
      'iss': 'product-list-demo',
    };

    // In a real app, you would use a proper JWT library with a secret key
    // For demo purposes, we'll create a simple mock token
    final headerBase64 = base64Url.encode(utf8.encode(jsonEncode(header)));
    final payloadBase64 = base64Url.encode(utf8.encode(jsonEncode(payload)));

    // Mock signature (in real app, this would be cryptographically signed)
    final signature = base64Url.encode(utf8.encode('mock_signature'));

    return '$headerBase64.$payloadBase64.$signature';
  }

  // Login with username and password
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // Check demo credentials
      if (_demoCredentials.containsKey(username) &&
          _demoCredentials[username] == password) {

        // Create mock user
        final user = User(
          id: _demoCredentials.keys.toList().indexOf(username) + 1,
          username: username,
          email: '$username@example.com',
          fullName: '${username.toUpperCase()} User',
          avatar: null,
        );

        // Generate JWT token
        final token = _generateJWTToken(user);

        // Store token securely
        await _secureStorage.write(key: _tokenKey, value: token);

        // Store user data in shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_userKey, jsonEncode(user.toJson()));

        return {
          'success': true,
          'user': user,
          'token': token,
          'message': 'Login successful',
        };
      } else {
        return {
          'success': false,
          'message': 'Invalid username or password',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred during login',
      };
    }
  }

  // Register new user (mock implementation)
  Future<Map<String, dynamic>> register(String username, String password, String email) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // Check if username already exists
      if (_demoCredentials.containsKey(username)) {
        return {
          'success': false,
          'message': 'Username already exists',
        };
      }

      // Create new user
      final user = User(
        id: Random().nextInt(9000) + 1000, // Random ID between 1000-9999
        username: username,
        email: email,
        fullName: '${username[0].toUpperCase()}${username.substring(1)} User',
        avatar: null,
      );

      // Generate JWT token
      final token = _generateJWTToken(user);

      // Store token securely
      await _secureStorage.write(key: _tokenKey, value: token);

      // Store user data in shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(user.toJson()));

      return {
        'success': true,
        'user': user,
        'token': token,
        'message': 'Registration successful',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred during registration',
      };
    }
  }

  // Get current user from stored token
  Future<User?> getCurrentUser() async {
    try {
      final token = await getToken();
      if (token == null || JwtDecoder.isExpired(token)) {
        return null;
      }

      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString(_userKey);

      if (userData != null) {
        final userJson = jsonDecode(userData);
        return User.fromJson(userJson);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  // Get stored token
  Future<String?> getToken() async {
    try {
      return await _secureStorage.read(key: _tokenKey);
    } catch (e) {
      return null;
    }
  }

  // Check if token is valid
  Future<bool> isTokenValid() async {
    try {
      final token = await getToken();
      if (token == null) return false;

      return !JwtDecoder.isExpired(token);
    } catch (e) {
      return false;
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      await _secureStorage.delete(key: _tokenKey);

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
    } catch (e) {
      // Continue even if cleanup fails
    }
  }

  // Clear token (for testing purposes)
  Future<void> clearToken() async {
    await logout();
  }

  // Refresh token (mock implementation)
  Future<String?> refreshToken() async {
    try {
      final user = await getCurrentUser();
      if (user == null) return null;

      final newToken = _generateJWTToken(user);
      await _secureStorage.write(key: _tokenKey, value: newToken);

      return newToken;
    } catch (e) {
      return null;
    }
  }

  // Get demo credentials list for UI display
  List<Map<String, String>> getDemoCredentials() {
    return _demoCredentials.entries.map((entry) => {
      'username': entry.key,
      'password': entry.value,
    }).toList();
  }
}