import 'package:flutter/foundation.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../data/datasources/auth_service.dart';
import '../../data/models/user.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  bool _isLoading = false;
  String? _error;

  // Getters
  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isGuest => _user == null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AuthProvider() {
    _initializeAuth();
  }

  // Initialize authentication state
  Future<void> _initializeAuth() async {
    await _loadUserFromStorage();
  }

  // Load user from secure storage
  Future<void> _loadUserFromStorage() async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await _authService.getToken();
      if (token != null && !JwtDecoder.isExpired(token)) {
        final user = await _authService.getCurrentUser();
        if (user != null) {
          _user = user;
        } else {
          // Token is invalid, clear it
          await _authService.clearToken();
        }
      } else if (token != null) {
        // Token expired, clear it
        await _authService.clearToken();
      }
    } catch (e) {
      _error = 'Failed to load user session';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login with username and password
  Future<bool> login(String username, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final result = await _authService.login(username, password);

      if (result['success']) {
        _user = result['user'];
        _error = null;
        return true;
      } else {
        _error = result['message'] ?? 'Login failed';
        return false;
      }
    } catch (e) {
      _error = 'An error occurred during login';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _authService.logout();
      _user = null;
      _error = null;
    } catch (e) {
      _error = 'Failed to logout';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Register new user (for future implementation)
  Future<bool> register(String username, String password, String email) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final result = await _authService.register(username, password, email);

      if (result['success']) {
        _user = result['user'];
        _error = null;
        return true;
      } else {
        _error = result['message'] ?? 'Registration failed';
        return false;
      }
    } catch (e) {
      _error = 'An error occurred during registration';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Refresh user session
  Future<void> refreshSession() async {
    if (_user != null) {
      await _loadUserFromStorage();
    }
  }

  // Update user profile (for future implementation)
  Future<bool> updateProfile(Map<String, dynamic> userData) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Mock implementation - in real app, this would call an API
      await Future.delayed(const Duration(seconds: 1));

      if (_user != null) {
        _user = User(
          id: _user!.id,
          username: userData['username'] ?? _user!.username,
          email: userData['email'] ?? _user!.email,
          fullName: userData['fullName'] ?? _user!.fullName,
          avatar: userData['avatar'] ?? _user!.avatar,
        );
      }

      return true;
    } catch (e) {
      _error = 'Failed to update profile';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}