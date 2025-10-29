/// Authentication Provider using Riverpod
///
/// A modern, compile-safe state management solution for authentication.
/// This provider handles user authentication, session management,
/// and user profile operations using Riverpod's state management.
///
/// Example usage:
/// ```dart
/// final authState = ref.watch(authProvider);
/// final authNotifier = ref.read(authProvider.notifier);
///
/// // Login
/// await authNotifier.login('username', 'password');
///
/// // Logout
/// await authNotifier.logout();
/// ```

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../services/auth_service.dart';
import '../models/user.dart';
import '../core/const/constants.dart';

// State class for authentication
class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  // Getters
  bool get isAuthenticated => user != null;
  bool get isGuest => user == null;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthState &&
        other.user == user &&
        other.isLoading == isLoading &&
        other.error == error;
  }

  @override
  int get hashCode => user.hashCode ^ isLoading.hashCode ^ error.hashCode;

  @override
  String toString() => 'AuthState(user: $user, isLoading: $isLoading, error: $error)';
}

// Notifier class for authentication state management
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AuthState()) {
    _initializeAuth();
  }

  // Initialize authentication state
  Future<void> _initializeAuth() async {
    await _loadUserFromStorage();
  }

  // Load user from secure storage
  Future<void> _loadUserFromStorage() async {
    try {
      state = state.copyWith(isLoading: true);

      final token = await _authService.getToken();
      if (token != null && !JwtDecoder.isExpired(token)) {
        final user = await _authService.getCurrentUser();
        if (user != null) {
          state = AuthState(user: user);
        } else {
          // Token is invalid, clear it
          await _authService.clearToken();
          state = const AuthState();
        }
      } else if (token != null) {
        // Token expired, clear it
        await _authService.clearToken();
        state = const AuthState();
      } else {
        state = const AuthState();
      }
    } catch (e) {
      state = AuthState(error: 'Failed to load user session: ${e.toString()}');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  // Login with username and password
  Future<bool> login(String username, String password) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final result = await _authService.login(username, password);

      if (result['success']) {
        state = AuthState(user: result['user']);
        return true;
      } else {
        state = AuthState(error: result['message'] ?? 'Login failed');
        return false;
      }
    } catch (e) {
      state = AuthState(error: 'An error occurred during login: ${e.toString()}');
      return false;
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      state = state.copyWith(isLoading: true);

      await _authService.logout();
      state = const AuthState();
    } catch (e) {
      state = AuthState(error: 'Failed to logout: ${e.toString()}');
    }
  }

  // Register new user
  Future<bool> register(String username, String password, String email) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final result = await _authService.register(username, password, email);

      if (result['success']) {
        state = AuthState(user: result['user']);
        return true;
      } else {
        state = AuthState(error: result['message'] ?? 'Registration failed');
        return false;
      }
    } catch (e) {
      state = AuthState(error: 'An error occurred during registration: ${e.toString()}');
      return false;
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Refresh user session
  Future<void> refreshSession() async {
    if (state.user != null) {
      await _loadUserFromStorage();
    }
  }

  // Update user profile
  Future<bool> updateProfile(Map<String, dynamic> userData) async {
    try {
      state = state.copyWith(isLoading: true);

      // Mock implementation - in real app, this would call an API
      await Future.delayed(AppConstants.loadingDelay);

      if (state.user != null) {
        final updatedUser = User(
          id: state.user!.id,
          username: userData['username'] ?? state.user!.username,
          email: userData['email'] ?? state.user!.email,
          fullName: userData['fullName'] ?? state.user!.fullName,
          avatar: userData['avatar'] ?? state.user!.avatar,
        );

        state = AuthState(user: updatedUser);
        return true;
      }

      return false;
    } catch (e) {
      state = AuthState(error: 'Failed to update profile: ${e.toString()}');
      return false;
    }
  }
}

// Provider definition
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authServiceProvider));
});

// Convenience providers for commonly used values
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authProvider).user;
});

final authErrorProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).error;
});

final authIsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoading;
});