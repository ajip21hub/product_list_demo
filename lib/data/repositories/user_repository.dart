/// User Repository Interface
///
/// Abstract interface defining the contract for user data operations.
/// This follows the Repository pattern, providing a clean abstraction
/// between the domain layer and data sources for user-related operations.
///
/// Implementations should handle:
/// - User profile data operations
/// - User preferences and settings
/// - User data persistence
/// - Cache management for user data
///
/// Example usage:
/// ```dart
/// final repository = UserRepositoryImpl(userService);
/// final result = await repository.getUserProfile(userId);
/// ```

import '../models/user.dart';
import 'product_repository.dart';

/// Abstract repository interface for user operations
abstract class UserRepository {
  /// Get user profile by ID
  ///
  /// [userId] - The ID of the user to fetch
  /// Returns [Result<User?>] with user profile or error
  Future<Result<User?>> getUserProfile(int userId);

  /// Update user profile
  ///
  /// [userId] - The ID of the user to update
  /// [userData] - Map containing user data to update
  /// Returns [Result<User>] with updated user profile or error
  Future<Result<User>> updateUserProfile(int userId, Map<String, dynamic> userData);

  /// Get current user preferences
  ///
  /// Returns [Result<Map<String, dynamic>>> with user preferences or error
  Future<Result<Map<String, dynamic>>> getUserPreferences();

  /// Update user preferences
  ///
  /// [preferences] - Map of preferences to update
  /// Returns [Result<bool>] indicating success or error
  Future<Result<bool>> updateUserPreferences(Map<String, dynamic> preferences);

  /// Delete user account
  ///
  /// [userId] - The ID of the user to delete
  /// Returns [Result<bool>] indicating success or error
  Future<Result<bool>> deleteUserAccount(int userId);

  /// Get user activity history
  ///
  /// [userId] - The ID of the user
  /// [limit] - Maximum number of activities to return
  /// Returns [Result<List<UserActivity>>> with activities or error
  Future<Result<List<UserActivity>>> getUserActivityHistory(int userId, {int limit = 10});

  /// Upload user avatar
  ///
  /// [userId] - The ID of the user
  /// [imageFile] - Path to the image file
  /// Returns [Result<String>] with avatar URL or error
  Future<Result<String>> uploadUserAvatar(int userId, String imageFile);

  /// Update user password
  ///
  /// [userId] - The ID of the user
  /// [currentPassword] - Current password for verification
  /// [newPassword] - New password to set
  /// Returns [Result<bool>] indicating success or error
  Future<Result<bool>> updateUserPassword(
    int userId,
    String currentPassword,
    String newPassword,
  );
}

/// User activity model for tracking user actions
class UserActivity {
  final int id;
  final int userId;
  final String activity;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  const UserActivity({
    required this.id,
    required this.userId,
    required this.activity,
    required this.timestamp,
    this.metadata,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserActivity &&
        other.id == id &&
        other.userId == userId &&
        other.activity == activity &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode => id.hashCode ^ userId.hashCode ^ activity.hashCode ^ timestamp.hashCode;

  @override
  String toString() => 'UserActivity(id: $id, userId: $userId, activity: $activity, timestamp: $timestamp)';
}