import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../models/user.dart';

class AuthService {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  // DummyJSON API demo credentials for testing
  static const Map<String, String> _demoCredentials = {
    'kminchelle': '0lelplR', // Valid DummyJSON credentials
    'emilys': 'emilyspass', // Custom demo for fallback
    'user': 'password', // Fallback credentials
  };

  // DummyJSON API endpoints
  static const String _baseUrl = 'https://dummyjson.com';
  static const String _loginEndpoint = '$_baseUrl/auth/login';
  static const String _meEndpoint = '$_baseUrl/auth/me';
  static const String _usersEndpoint = '$_baseUrl/users';

  // Login with username and password using DummyJSON API
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      // First try DummyJSON API for real authentication
      final apiResult = await _loginWithDummyJSON(username, password);
      if (apiResult['success'] == true) {
        return apiResult;
      }

      // Fallback to demo credentials for testing purposes
      if (_demoCredentials.containsKey(username) &&
          _demoCredentials[username] == password) {
        return await _createDemoUserSession(username);
      }

      return {
        'success': false,
        'message': 'Invalid username or password. Try: kminchelle / 0lelplR',
      };
    } catch (e) {
      return {'success': false, 'message': 'Login failed: ${e.toString()}'};
    }
  }

  // Login with DummyJSON API
  Future<Map<String, dynamic>> _loginWithDummyJSON(
    String username,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(_loginEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
          'expiresInMins': 1440, // 24 hours
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final loginData = jsonDecode(response.body);

        // Create user object from DummyJSON response
        final user = User(
          id: loginData['id'] ?? 0,
          username: loginData['username'] ?? username,
          email: loginData['email'] ?? '$username@dummyjson.com',
          fullName:
              loginData['firstName'] != null && loginData['lastName'] != null
              ? '${loginData['firstName']} ${loginData['lastName']}'
              : username.toUpperCase(),
          avatar: loginData['image'],
        );

        final token = loginData['token'] ?? '';

        // Store token securely
        await _secureStorage.write(key: _tokenKey, value: token);

        // Store user data in shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_userKey, jsonEncode(user.toJson()));

        return {
          'success': true,
          'user': user,
          'token': token,
          'message': 'Login successful with DummyJSON API',
        };
      }
    } catch (e) {
      // API call failed, will fall back to demo credentials
    }

    return {'success': false};
  }

  // Create demo user session for fallback authentication
  Future<Map<String, dynamic>> _createDemoUserSession(String username) async {
    final user = User(
      id: _demoCredentials.keys.toList().indexOf(username) + 1,
      username: username,
      email: '$username@example.com',
      fullName: '${username[0].toUpperCase()}${username.substring(1)} User',
      avatar: null,
    );

    // Generate mock JWT token for demo user
    final token = _generateMockJWTToken(user);

    // Store token securely
    await _secureStorage.write(key: _tokenKey, value: token);

    // Store user data in shared preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));

    return {
      'success': true,
      'user': user,
      'token': token,
      'message': 'Login successful with demo credentials',
    };
  }

  // Generate mock JWT token for demo users
  String _generateMockJWTToken(User user) {
    final header = {'alg': 'HS256', 'typ': 'JWT'};

    final now = DateTime.now();
    final expiry = now.add(const Duration(hours: 24));

    final payload = {
      'sub': user.id.toString(),
      'username': user.username,
      'email': user.email,
      'fullName': user.fullName,
      'iat': now.millisecondsSinceEpoch ~/ 1000,
      'exp': expiry.millisecondsSinceEpoch ~/ 1000,
      'iss': 'product-list-demo',
    };

    final headerBase64 = base64Url.encode(utf8.encode(jsonEncode(header)));
    final payloadBase64 = base64Url.encode(utf8.encode(jsonEncode(payload)));
    final signature = base64Url.encode(utf8.encode('mock_signature'));

    return '$headerBase64.$payloadBase64.$signature';
  }

  // Register new user (mock implementation)
  Future<Map<String, dynamic>> register(
    String username,
    String password,
    String email,
  ) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // Check if username already exists
      if (_demoCredentials.containsKey(username)) {
        return {'success': false, 'message': 'Username already exists'};
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
      final token = _generateMockJWTToken(user);

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

  // Refresh token using DummyJSON API
  Future<String?> refreshToken() async {
    try {
      final currentToken = await getToken();
      if (currentToken == null) return null;

      // For DummyJSON, we need to get user info and generate new token
      final user = await getCurrentUser();
      if (user == null) return null;

      // Try to get fresh user data with current token
      final response = await http.get(
        Uri.parse(_meEndpoint),
        headers: {'Authorization': 'Bearer $currentToken'},
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // DummyJSON doesn't provide refresh endpoint, so we return current token
        return currentToken;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  // Get demo credentials list for UI display
  List<Map<String, String>> getDemoCredentials() {
    return [
      {
        'username': 'kminchelle',
        'password': '0lelplR',
        'description': 'DummyJSON API User',
      },
      {
        'username': 'emilys',
        'password': 'emilyspass',
        'description': 'Demo User',
      },
      {
        'username': 'user',
        'password': 'password',
        'description': 'Fallback User',
      },
    ];
  }

  // Fetch user details from DummyJSON API
  Future<User?> fetchUserDetails(String username) async {
    try {
      final uri = Uri.parse(
        '$_usersEndpoint/filter',
      ).replace(queryParameters: {'key': 'username', 'value': username});

      final response = await http.get(uri);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = jsonDecode(response.body);
        final users = responseData['users'] as List;
        if (users.isNotEmpty) {
          final userData = users.first;
          return User(
            id: userData['id'] ?? 0,
            username: userData['username'] ?? '',
            email: userData['email'] ?? '',
            fullName:
                '${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}'
                    .trim(),
            avatar: userData['image'],
          );
        }
      }
    } catch (e) {
      // Return null if API call fails
    }
    return null;
  }
}
