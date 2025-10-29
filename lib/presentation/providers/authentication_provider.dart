/// Authentication Provider using Riverpod
///
/// A focused authentication state management solution following SOLID principles.
/// This provider handles only authentication operations (login, logout, register)
/// and delegates session management and user profile operations to specialized providers.
///
/// Responsibilities (Single Responsibility Principle):
/// - Authentication state management
/// - Login/logout operations
/// - User registration
/// - Authentication error handling
///
/// Example usage:
/// ```dart
/// final authState = ref.watch(authenticationProvider);
/// final authNotifier = ref.read(authenticationProvider.notifier);
///
/// // Login
/// await authNotifier.login('username', 'password');
///
/// // Logout
/// await authNotifier.logout();
/// ```

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/session_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/models/user.dart';
import '../../core/dependency_injection.dart';

// State class for authentication
class AuthenticationState {
  final User? user;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  const AuthenticationState({
    this.user,
    this.isLoading = false,
    this.error,
  }) : isAuthenticated = user != null;

  AuthenticationState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return AuthenticationState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthenticationState &&
        other.user == user &&
        other.isLoading == isLoading &&
        other.error == error;
  }

  @override
  int get hashCode => user.hashCode ^ isLoading.hashCode ^ error.hashCode;

  @override
  String toString() => 'AuthenticationState(user: $user, isLoading: $isLoading, error: $error)';
}

// Notifier class for authentication state management
class AuthenticationNotifier extends StateNotifier<AuthenticationState> {
  final SessionRepository _sessionRepository;
  final UserRepository _userRepository;

  AuthenticationNotifier(
    this._sessionRepository,
    this._userRepository,
  ) : super(const AuthenticationState()) {
    _initializeAuthentication();
  }

  // Initialize authentication state on startup
  Future<void> _initializeAuthentication() async {
    await _loadCurrentUser();
  }

  // Load current user from session
  Future<void> _loadCurrentUser() async {
    try {
      state = state.copyWith(isLoading: true);

      final sessionResult = await _sessionRepository.getCurrentSession();

      await sessionResult.fold(
        onFailure: (error) async {
          // Clear invalid session
          await _sessionRepository.clearSession();
          state = state.copyWith(isLoading: false);
        },
        onSuccess: (session) async {
          if (session != null && session.isValid) {
            // Load user profile
            final userResult = await _userRepository.getUserProfile(session.userId);

            await userResult.fold(
              onFailure: (error) async {
                // Clear invalid session
                await _sessionRepository.clearSession();
                state = state.copyWith(isLoading: false);
              },
              onSuccess: (user) async {
                if (user != null) {
                  state = AuthenticationState(user: user);
                } else {
                  // User not found, clear session
                  await _sessionRepository.clearSession();
                  state = state.copyWith(isLoading: false);
                }
              },
            );
          } else {
            state = state.copyWith(isLoading: false);
          }
        },
      );
    } catch (e) {
      state = AuthenticationState(error: 'Failed to initialize authentication: ${e.toString()}');
    }
  }

  // Login with username and password
  Future<bool> login(String username, String password) async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);

      // Mock authentication - in real app, would call authentication API
      await Future.delayed(const Duration(seconds: 1));

      // Mock successful login
      if (username.isNotEmpty && password.length >= 6) {
        final userId = _generateUserId(username);
        final mockUser = User(
          id: userId,
          username: username,
          email: '$username@example.com',
          fullName: '${username.toUpperCase()} User',
        );

        // Create session
        final sessionResult = await _sessionRepository.createSession(
          userId,
          username,
          rememberMe: true,
        );

        return await sessionResult.fold(
          onFailure: (error) async {
            state = AuthenticationState(error: 'Failed to create session: ${error.toString()}');
            return false;
          },
          onSuccess: (session) async {
            state = AuthenticationState(user: mockUser);
            return true;
          },
        );
      } else {
        state = AuthenticationState(error: 'Invalid credentials');
        return false;
      }
    } catch (e) {
      state = AuthenticationState(error: 'Login failed: ${e.toString()}');
      return false;
    }
  }

  // Register new user
  Future<bool> register(String username, String password, String email) async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);

      // Validate input
      if (username.length < 3) {
        state = AuthenticationState(error: 'Username must be at least 3 characters');
        return false;
      }

      if (password.length < 6) {
        state = AuthenticationState(error: 'Password must be at least 6 characters');
        return false;
      }

      if (!email.contains('@')) {
        state = AuthenticationState(error: 'Please enter a valid email address');
        return false;
      }

      // Mock registration - in real app, would call registration API
      await Future.delayed(const Duration(seconds: 1));

      // Create mock user
      final userId = _generateUserId(username);
      final newUser = User(
        id: userId,
        username: username,
        email: email,
        fullName: '${username.toUpperCase()} User',
      );

      // Create session after successful registration
      final sessionResult = await _sessionRepository.createSession(
        userId,
        username,
        rememberMe: true,
      );

      return await sessionResult.fold(
        onFailure: (error) async {
          state = AuthenticationState(error: 'Registration successful but failed to create session: ${error.toString()}');
          return false;
        },
        onSuccess: (session) async {
          state = AuthenticationState(user: newUser);
          return true;
        },
      );
    } catch (e) {
      state = AuthenticationState(error: 'Registration failed: ${e.toString()}');
      return false;
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      state = state.copyWith(isLoading: true);

      final result = await _sessionRepository.clearSession();

      await result.fold(
        onFailure: (error) {
          // Even if clearing session fails, we should log out locally
          state = const AuthenticationState();
        },
        onSuccess: (_) {
          state = const AuthenticationState();
        },
      );
    } catch (e) {
      // Even on error, clear local state
      state = const AuthenticationState();
    }
  }

  // Clear authentication error
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  // Refresh authentication state
  Future<void> refreshAuthentication() async {
    await _loadCurrentUser();
  }

  // Mock helper method to generate user ID from username
  int _generateUserId(String username) {
    // Simple hash function for demo purposes
    return username.hashCode.abs() % 10000 + 1;
  }
}

// Provider definitions

// Provider for SessionRepository
final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  return DependencyInjection.get<SessionRepository>();
});

// Provider for UserRepository
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return DependencyInjection.get<UserRepository>();
});

// Main authentication provider
final authenticationProvider = StateNotifierProvider<AuthenticationNotifier, AuthenticationState>((ref) {
  final sessionRepository = ref.watch(sessionRepositoryProvider);
  final userRepository = ref.watch(userRepositoryProvider);

  return AuthenticationNotifier(sessionRepository, userRepository);
});

// Convenience providers for commonly used values
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authenticationProvider).isAuthenticated;
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authenticationProvider).user;
});

final authLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authenticationProvider).isLoading;
});

final authErrorProvider = Provider<String?>((ref) {
  return ref.watch(authenticationProvider).error;
});