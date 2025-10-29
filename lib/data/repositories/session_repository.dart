/// Session Repository Interface
///
/// Abstract interface defining the contract for session management operations.
/// This follows the Repository pattern, providing a clean abstraction
/// between the domain layer and data sources for session-related operations.
///
/// Implementations should handle:
/// - Session persistence and retrieval
/// - Token management and validation
/// - Security operations
/// - Session cleanup and expiration
///
/// Example usage:
/// ```dart
/// final repository = SessionRepositoryImpl(tokenService, secureStorage);
/// final result = await repository.createSession(userData);
/// ```

import 'product_repository.dart';

/// Session data model
class UserSession {
  final String token;
  final DateTime expiresAt;
  final int userId;
  final String username;
  final DateTime createdAt;

  const UserSession({
    required this.token,
    required this.expiresAt,
    required this.userId,
    required this.username,
    required this.createdAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isValid => !isExpired && token.isNotEmpty;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserSession &&
        other.token == token &&
        other.expiresAt == expiresAt &&
        other.userId == userId &&
        other.username == username &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode =>
      token.hashCode ^
      expiresAt.hashCode ^
      userId.hashCode ^
      username.hashCode ^
      createdAt.hashCode;

  @override
  String toString() => 'UserSession(userId: $userId, username: $username, valid: $isValid)';
}

/// Abstract repository interface for session operations
abstract class SessionRepository {
  /// Create a new user session
  ///
  /// [userId] - The ID of the user
  /// [username] - The username of the user
  /// [rememberMe] - Whether to persist the session
  /// Returns [Result<UserSession>] with session data or error
  Future<Result<UserSession>> createSession(int userId, String username, {bool rememberMe = false});

  /// Get current active session
  ///
  /// Returns [Result<UserSession?>] with current session or null if none exists
  Future<Result<UserSession?>> getCurrentSession();

  /// Validate session token
  ///
  /// [token] - The session token to validate
  /// Returns [Result<bool>] indicating if token is valid or error
  Future<Result<bool>> validateToken(String token);

  /// Refresh session token
  ///
  /// Returns [Result<UserSession>] with refreshed session or error
  Future<Result<UserSession>> refreshSession();

  /// Clear current session (logout)
  ///
  /// Returns [Result<bool>] indicating success or error
  Future<Result<bool>> clearSession();

  /// Check if session exists and is valid
  ///
  /// Returns [Result<bool>] indicating if session is valid or error
  Future<Result<bool>> hasValidSession();

  /// Extend session expiration
  ///
  /// [duration] - How long to extend the session
  /// Returns [Result<UserSession>] with extended session or error
  Future<Result<UserSession>> extendSession(Duration duration);

  /// Get all active sessions for user
  ///
  /// [userId] - The ID of the user
  /// Returns [Result<List<UserSession>>> with active sessions or error
  Future<Result<List<UserSession>>> getUserSessions(int userId);

  /// Revoke specific session
  ///
  /// [sessionId] - The session token to revoke
  /// Returns [Result<bool>] indicating success or error
  Future<Result<bool>> revokeSession(String sessionId);

  /// Revoke all sessions except current
  ///
  /// Returns [Result<bool>] indicating success or error
  Future<Result<bool>> revokeOtherSessions();

  /// Update session metadata
  ///
  /// [metadata] - Additional session data to store
  /// Returns [Result<bool>] indicating success or error
  Future<Result<bool>> updateSessionMetadata(Map<String, dynamic> metadata);
}