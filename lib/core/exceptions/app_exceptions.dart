/// Custom Exception Classes
///
/// Centralized exception hierarchy for the application.
/// This provides specific, typed exceptions for different error scenarios,
/// making error handling more precise and maintainable.
///
/// Features:
/// - Hierarchical exception structure
/// - Detailed error messages
/// - Error codes for programmatic handling
/// - Context information for debugging
///
/// Example usage:
/// ```dart
/// try {
///   await repository.getProducts();
/// } on NetworkException catch (e) {
///   print('Network error: ${e.message}');
/// } on ValidationException catch (e) {
///   print('Validation error: ${e.errors}');
/// }
/// ```

// Base application exception
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const AppException({
    required this.message,
    this.code,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() => 'AppException: $message${code != null ? ' (Code: $code)' : ''}';
}

// Network-related exceptions
class NetworkException extends AppException {
  final int? statusCode;
  final String? url;

  const NetworkException({
    required String message,
    this.statusCode,
    this.url,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
        );

  @override
  String toString() => 'NetworkException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}${url != null ? ' (URL: $url)' : ''}';
}

class ServerException extends NetworkException {
  const ServerException({
    required String message,
    required int statusCode,
    String? url,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          statusCode: statusCode,
          url: url,
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

class TimeoutException extends NetworkException {
  final Duration timeout;

  const TimeoutException({
    required String message,
    required this.timeout,
    String? url,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          url: url,
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
        );

  @override
  String toString() => 'TimeoutException: $message (Timeout: ${timeout.inSeconds}s)';
}

class ConnectionException extends NetworkException {
  const ConnectionException({
    required String message,
    String? url,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          url: url,
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

// Authentication exceptions
class AuthenticationException extends AppException {
  const AuthenticationException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

class InvalidCredentialsException extends AuthenticationException {
  const InvalidCredentialsException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

class TokenExpiredException extends AuthenticationException {
  final DateTime? expiredAt;

  const TokenExpiredException({
    required String message,
    this.expiredAt,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
        );

  @override
  String toString() => 'TokenExpiredException: $message${expiredAt != null ? ' (Expired: $expiredAt)' : ''}';
}

class SessionInvalidException extends AuthenticationException {
  const SessionInvalidException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

// Validation exceptions
class ValidationException extends AppException {
  final Map<String, List<String>> errors;

  const ValidationException({
    required this.errors,
    String? message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message ?? 'Validation failed',
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
        );

  @override
  String toString() {
    final errorDetails = errors.entries
        .map((entry) => '${entry.key}: ${entry.value.join(', ')}')
        .join('; ');
    return 'ValidationException: $message - $errorDetails';
  }
}

class RequiredFieldException extends ValidationException {
  final List<String> missingFields;

  RequiredFieldException({
    required this.missingFields,
    String? message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          errors: {
            for (final field in missingFields) field: ['This field is required']
          },
          message: message ?? 'Required fields are missing',
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
        );

  @override
  String toString() => 'RequiredFieldException: $message - Missing: ${missingFields.join(', ')}';
}

// Data-related exceptions
class DataException extends AppException {
  const DataException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

class NotFoundException extends DataException {
  final String? resourceType;
  final String? resourceId;

  const NotFoundException({
    required String message,
    this.resourceType,
    this.resourceId,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
        );

  @override
  String toString() => 'NotFoundException: $message${resourceType != null ? ' (Type: $resourceType)' : ''}${resourceId != null ? ' (ID: $resourceId)' : ''}';
}

class DuplicateResourceException extends DataException {
  final String? resourceType;
  final String? duplicateField;

  const DuplicateResourceException({
    required String message,
    this.resourceType,
    this.duplicateField,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

// Cache exceptions
class CacheException extends AppException {
  const CacheException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

class CacheMissException extends CacheException {
  final String? cacheKey;

  const CacheMissException({
    required String message,
    this.cacheKey,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

// Business logic exceptions
class BusinessLogicException extends AppException {
  const BusinessLogicException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

class InsufficientPermissionException extends BusinessLogicException {
  final String? requiredPermission;
  final String? userRole;

  const InsufficientPermissionException({
    required String message,
    this.requiredPermission,
    this.userRole,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

class ResourceLockedException extends BusinessLogicException {
  final String? lockedBy;
  final DateTime? lockExpiresAt;

  const ResourceLockedException({
    required String message,
    this.lockedBy,
    this.lockExpiresAt,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

// Configuration exceptions
class ConfigurationException extends AppException {
  const ConfigurationException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

class MissingConfigurationException extends ConfigurationException {
  final String? configKey;

  const MissingConfigurationException({
    required String message,
    this.configKey,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}