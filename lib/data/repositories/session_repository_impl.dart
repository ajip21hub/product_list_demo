/// Session Repository Implementation
///
/// Concrete implementation of SessionRepository using various services.
/// Handles all session data operations with proper error handling,
/// security, and persistence logic.
///
/// This implementation:
/// - Manages session lifecycle and validation
/// - Handles token storage and retrieval
/// - Implements session security features
/// - Provides consistent error handling
///
/// Example usage:
/// ```dart
/// final repository = SessionRepositoryImpl(authService);
/// final result = await repository.createSession(userId, username);
/// result.fold(
///   (error) => print('Error: $error'),
///   (session) => print('Session: $session'),
/// );
/// ```

import 'dart:async';
import '../repositories/session_repository.dart';
import '../repositories/product_repository.dart';
import '../datasources/auth_service.dart';
import '../../core/const/constants.dart';

/// Concrete implementation of SessionRepository
class SessionRepositoryImpl implements SessionRepository {
  final AuthService _authService;
  UserSession? _cachedSession;

  SessionRepositoryImpl(this._authService);

  @override
  Future<Result<UserSession>> createSession(int userId, String username, {bool rememberMe = false}) async {
    try {
      // Mock implementation - in real app, this would call an authentication API
      await Future.delayed(const Duration(seconds: 1));

      // Generate mock JWT token
      final token = 'mock_jwt_token_${userId}_${DateTime.now().millisecondsSinceEpoch}';

      // Set expiration based on rememberMe preference
      final expiration = rememberMe
        ? DateTime.now().add(const Duration(days: 30))
        : DateTime.now().add(const Duration(hours: 24));

      final session = UserSession(
        token: token,
        expiresAt: expiration,
        userId: userId,
        username: username,
        createdAt: DateTime.now(),
      );

      // Token is already stored by the AuthService during login

      // Cache session
      _cachedSession = session;

      return Result.success(session);
    } catch (e) {
      return Result.failure(Exception('Failed to create session: $e'));
    }
  }

  @override
  Future<Result<UserSession?>> getCurrentSession() async {
    try {
      // Return cached session if available and valid
      if (_cachedSession != null && _cachedSession!.isValid) {
        return Result.success(_cachedSession);
      }

      // Try to get token from storage
      final token = await _authService.getToken();
      if (token == null) {
        return Result.success(null);
      }

      // Mock token parsing - in real app, would decode JWT
      final userId = _extractUserIdFromToken(token);
      final username = _extractUsernameFromToken(token);
      final expiresAt = _extractExpirationFromToken(token);

      if (userId == null || username == null || expiresAt == null) {
        // Invalid token, clear it
        await _authService.clearToken();
        return Result.success(null);
      }

      final session = UserSession(
        token: token,
        expiresAt: expiresAt,
        userId: userId,
        username: username,
        createdAt: DateTime.now(), // Mock creation time
      );

      // Cache session
      _cachedSession = session;

      return Result.success(session);
    } catch (e) {
      return Result.failure(Exception('Failed to get current session: $e'));
    }
  }

  @override
  Future<Result<bool>> validateToken(String token) async {
    try {
      // Mock validation - in real app, would verify JWT signature and expiration
      await Future.delayed(const Duration(milliseconds: 300));

      if (token.isEmpty) {
        return Result.success(false);
      }

      // Check if token has expired
      final expiresAt = _extractExpirationFromToken(token);
      if (expiresAt == null || DateTime.now().isAfter(expiresAt)) {
        return Result.success(false);
      }

      return Result.success(true);
    } catch (e) {
      return Result.failure(Exception('Failed to validate token: $e'));
    }
  }

  @override
  Future<Result<UserSession>> refreshSession() async {
    try {
      final currentSessionResult = await getCurrentSession();

      return currentSessionResult.fold(
        onFailure: (error) => Result.failure(error),
        onSuccess: (session) async {
          if (session == null) {
            return Result.failure(Exception('No active session to refresh'));
          }

          // Create new session with extended expiration
          return await createSession(
            session.userId,
            session.username,
            rememberMe: true, // Extended session implies remember me
          );
        },
      );
    } catch (e) {
      return Result.failure(Exception('Failed to refresh session: $e'));
    }
  }

  @override
  Future<Result<bool>> clearSession() async {
    try {
      await _authService.logout();
      _cachedSession = null;
      return Result.success(true);
    } catch (e) {
      return Result.failure(Exception('Failed to clear session: $e'));
    }
  }

  @override
  Future<Result<bool>> hasValidSession() async {
    try {
      final sessionResult = await getCurrentSession();

      return sessionResult.fold(
        onFailure: (error) => Result.failure(error),
        onSuccess: (session) {
          final isValid = session != null && session.isValid;
          return Result.success(isValid);
        },
      );
    } catch (e) {
      return Result.failure(Exception('Failed to check session validity: $e'));
    }
  }

  @override
  Future<Result<UserSession>> extendSession(Duration duration) async {
    try {
      final currentSessionResult = await getCurrentSession();

      return currentSessionResult.fold(
        onFailure: (error) => Result.failure(error),
        onSuccess: (session) async {
          if (session == null) {
            return Result.failure(Exception('No active session to extend'));
          }

          // Create extended session
          final extendedSession = UserSession(
            token: session.token,
            expiresAt: session.expiresAt.add(duration),
            userId: session.userId,
            username: session.username,
            createdAt: session.createdAt,
          );

          // Update cached session
          _cachedSession = extendedSession;

          return Result.success(extendedSession);
        },
      );
    } catch (e) {
      return Result.failure(Exception('Failed to extend session: $e'));
    }
  }

  @override
  Future<Result<List<UserSession>>> getUserSessions(int userId) async {
    try {
      // Mock implementation - in real app, would fetch from backend
      await Future.delayed(const Duration(milliseconds: 500));

      final currentSessionResult = await getCurrentSession();
      final currentSession = currentSessionResult.fold(
        onFailure: (_) => null,
        onSuccess: (session) => session,
      );

      final sessions = <UserSession>[];

      if (currentSession != null && currentSession.userId == userId) {
        sessions.add(currentSession);
      }

      // Add mock sessions for demonstration
      if (userId == 1) {
        sessions.addAll([
          UserSession(
            token: 'mock_token_2',
            expiresAt: DateTime.now().add(const Duration(hours: 12)),
            userId: userId,
            username: 'john_doe',
            createdAt: DateTime.now().subtract(const Duration(days: 1)),
          ),
          UserSession(
            token: 'mock_token_3',
            expiresAt: DateTime.now().add(const Duration(hours: 6)),
            userId: userId,
            username: 'john_doe',
            createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          ),
        ]);
      }

      return Result.success(sessions);
    } catch (e) {
      return Result.failure(Exception('Failed to get user sessions: $e'));
    }
  }

  @override
  Future<Result<bool>> revokeSession(String sessionId) async {
    try {
      // Mock implementation - in real app, would call backend API
      await Future.delayed(const Duration(milliseconds: 300));

      // If revoking current session, clear cache
      if (_cachedSession?.token == sessionId) {
        _cachedSession = null;
      }

      return Result.success(true);
    } catch (e) {
      return Result.failure(Exception('Failed to revoke session: $e'));
    }
  }

  @override
  Future<Result<bool>> revokeOtherSessions() async {
    try {
      // Mock implementation - in real app, would call backend API
      await Future.delayed(const Duration(milliseconds: 500));

      // Keep only current session active
      if (_cachedSession != null) {
        return Result.success(true);
      }

      return Result.success(true);
    } catch (e) {
      return Result.failure(Exception('Failed to revoke other sessions: $e'));
    }
  }

  @override
  Future<Result<bool>> updateSessionMetadata(Map<String, dynamic> metadata) async {
    try {
      // Mock implementation - in real app, would store metadata
      await Future.delayed(const Duration(milliseconds: 200));

      // Validate metadata keys
      final allowedKeys = ['deviceInfo', 'ipAddress', 'userAgent', 'lastActivity'];
      for (final key in metadata.keys) {
        if (!allowedKeys.contains(key)) {
          return Result.failure(Exception('Invalid metadata key: $key'));
        }
      }

      return Result.success(true);
    } catch (e) {
      return Result.failure(Exception('Failed to update session metadata: $e'));
    }
  }

  // Helper methods for mock token parsing
  int? _extractUserIdFromToken(String token) {
    // Mock implementation - in real app, would decode JWT
    if (token.contains('mock_jwt_token_1_')) return 1;
    if (token.contains('mock_jwt_token_')) {
      final parts = token.split('_');
      if (parts.length >= 3) {
        return int.tryParse(parts[3]) ?? 1;
      }
    }
    return null;
  }

  String? _extractUsernameFromToken(String token) {
    // Mock implementation - in real app, would decode JWT
    if (token.contains('mock_jwt_token')) return 'john_doe';
    return null;
  }

  DateTime? _extractExpirationFromToken(String token) {
    // Mock implementation - in real app, would decode JWT
    return DateTime.now().add(const Duration(hours: 24));
  }
}