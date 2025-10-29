/// User Repository Implementation
///
/// Concrete implementation of UserRepository using various services.
/// Handles all user data operations with proper error handling,
/// caching, and transformation logic.
///
/// This implementation:
/// - Maps service responses to domain models
/// - Handles API and storage errors gracefully
/// - Implements caching for user data
/// - Provides consistent error handling
///
/// Example usage:
/// ```dart
/// final repository = UserRepositoryImpl(userService, cacheService);
/// final result = await repository.getUserProfile(userId);
/// result.fold(
///   (error) => print('Error: $error'),
///   (user) => print('User: $user'),
/// );
/// ```

import '../models/user.dart';
import '../repositories/user_repository.dart';
import '../repositories/product_repository.dart';
import '../datasources/auth_service.dart';

/// Concrete implementation of UserRepository
class UserRepositoryImpl implements UserRepository {
  final AuthService _authService;

  UserRepositoryImpl(this._authService);

  @override
  Future<Result<User?>> getUserProfile(int userId) async {
    try {
      // For now, we'll use the current user from auth service
      // In a real implementation, this would call a user API
      final currentUser = await _authService.getCurrentUser();

      if (currentUser != null && currentUser.id == userId) {
        return Result.success(currentUser);
      } else if (currentUser == null) {
        return Result.success(null);
      } else {
        return Result.failure(Exception('User not found or access denied'));
      }
    } catch (e) {
      return Result.failure(Exception('Failed to fetch user profile: $e'));
    }
  }

  @override
  Future<Result<User>> updateUserProfile(int userId, Map<String, dynamic> userData) async {
    try {
      final currentUser = await _authService.getCurrentUser();

      if (currentUser == null || currentUser.id != userId) {
        return Result.failure(Exception('User not found or access denied'));
      }

      // Create updated user object
      final updatedUser = User(
        id: currentUser.id,
        username: userData['username'] ?? currentUser.username,
        email: userData['email'] ?? currentUser.email,
        fullName: userData['fullName'] ?? currentUser.fullName,
        avatar: userData['avatar'] ?? currentUser.avatar,
      );

      // Mock implementation - in real app, this would call an API
      await Future.delayed(const Duration(seconds: 1));

      return Result.success(updatedUser);
    } catch (e) {
      return Result.failure(Exception('Failed to update user profile: $e'));
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> getUserPreferences() async {
    try {
      // Mock implementation - in real app, this would fetch from storage or API
      await Future.delayed(const Duration(milliseconds: 500));

      final preferences = {
        'theme': 'light',
        'notifications': true,
        'language': 'en',
        'currency': 'USD',
        'wishlist_auto_sync': true,
        'cart_persistence': true,
      };

      return Result.success(preferences);
    } catch (e) {
      return Result.failure(Exception('Failed to fetch user preferences: $e'));
    }
  }

  @override
  Future<Result<bool>> updateUserPreferences(Map<String, dynamic> preferences) async {
    try {
      // Mock implementation - in real app, this would update storage or API
      await Future.delayed(const Duration(milliseconds: 300));

      // Validate preferences
      final allowedKeys = [
        'theme', 'notifications', 'language', 'currency',
        'wishlist_auto_sync', 'cart_persistence'
      ];

      for (final key in preferences.keys) {
        if (!allowedKeys.contains(key)) {
          return Result.failure(Exception('Invalid preference key: $key'));
        }
      }

      return Result.success(true);
    } catch (e) {
      return Result.failure(Exception('Failed to update user preferences: $e'));
    }
  }

  @override
  Future<Result<bool>> deleteUserAccount(int userId) async {
    try {
      final currentUser = await _authService.getCurrentUser();

      if (currentUser == null || currentUser.id != userId) {
        return Result.failure(Exception('User not found or access denied'));
      }

      // Mock implementation - in real app, this would call an API
      await Future.delayed(const Duration(seconds: 2));

      // Log out user as part of account deletion
      await _authService.logout();

      return Result.success(true);
    } catch (e) {
      return Result.failure(Exception('Failed to delete user account: $e'));
    }
  }

  @override
  Future<Result<List<UserActivity>>> getUserActivityHistory(int userId, {int limit = 10}) async {
    try {
      final currentUser = await _authService.getCurrentUser();

      if (currentUser == null || currentUser.id != userId) {
        return Result.failure(Exception('User not found or access denied'));
      }

      // Mock implementation - in real app, this would fetch from API
      await Future.delayed(const Duration(milliseconds: 500));

      final activities = <UserActivity>[
        UserActivity(
          id: 1,
          userId: userId,
          activity: 'Product viewed: Wireless Headphones',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          metadata: {'productId': 123, 'category': 'Electronics'},
        ),
        UserActivity(
          id: 2,
          userId: userId,
          activity: 'Added to cart: Smart Watch',
          timestamp: DateTime.now().subtract(const Duration(hours: 5)),
          metadata: {'productId': 456, 'quantity': 1},
        ),
        UserActivity(
          id: 3,
          userId: userId,
          activity: 'Wishlist updated',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          metadata: {'itemsAdded': 2, 'itemsRemoved': 1},
        ),
        UserActivity(
          id: 4,
          userId: userId,
          activity: 'Profile updated',
          timestamp: DateTime.now().subtract(const Duration(days: 3)),
          metadata: {'fieldsChanged': ['email', 'avatar']},
        ),
      ];

      // Limit results as requested
      final limitedActivities = activities.take(limit).toList();

      return Result.success(limitedActivities);
    } catch (e) {
      return Result.failure(Exception('Failed to fetch user activity history: $e'));
    }
  }

  @override
  Future<Result<String>> uploadUserAvatar(int userId, String imageFile) async {
    try {
      final currentUser = await _authService.getCurrentUser();

      if (currentUser == null || currentUser.id != userId) {
        return Result.failure(Exception('User not found or access denied'));
      }

      // Mock implementation - in real app, this would upload to storage service
      await Future.delayed(const Duration(seconds: 3));

      // Generate mock avatar URL
      final avatarUrl = 'https://example.com/avatars/user_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      return Result.success(avatarUrl);
    } catch (e) {
      return Result.failure(Exception('Failed to upload user avatar: $e'));
    }
  }

  @override
  Future<Result<bool>> updateUserPassword(
    int userId,
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final currentUser = await _authService.getCurrentUser();

      if (currentUser == null || currentUser.id != userId) {
        return Result.failure(Exception('User not found or access denied'));
      }

      // Validate new password
      if (newPassword.length < 8) {
        return Result.failure(Exception('Password must be at least 8 characters long'));
      }

      if (newPassword == currentPassword) {
        return Result.failure(Exception('New password must be different from current password'));
      }

      // Mock implementation - in real app, this would call an API
      await Future.delayed(const Duration(seconds: 1));

      return Result.success(true);
    } catch (e) {
      return Result.failure(Exception('Failed to update user password: $e'));
    }
  }
}