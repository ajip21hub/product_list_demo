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
library;

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
  String toString() => '$typeName: $message${code != null ? ' (Code: $code)' : ''}';

  /// Nama yang ditampilkan di toString(); subclass menimpanya.
  String get typeName => 'AppException';
}

// Network-related exceptions
class NetworkException extends AppException {
  final int? statusCode;
  final String? url;

  const NetworkException({
    required super.message,
    this.statusCode,
    this.url,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() => '$runtimeType: $message${code != null ? ' (Code: $code)' : ''}${statusCode != null ? ' (Status: $statusCode)' : ''}${url != null ? ' (URL: $url)' : ''}';
}

class ServerException extends NetworkException {
  const ServerException({
    required super.message,
    required int super.statusCode,
    super.url,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

class TimeoutException extends NetworkException {
  final Duration timeout;

  const TimeoutException({
    required super.message,
    required this.timeout,
    super.url,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() => 'TimeoutException: $message (Timeout: ${timeout.inSeconds}s)';
}

class ConnectionException extends NetworkException {
  @override
  String get typeName => 'ConnectionException';

  const ConnectionException({
    required super.message,
    super.url,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

// Authentication exceptions
class AuthenticationException extends AppException {
  @override
  String get typeName => 'AuthenticationException';

  const AuthenticationException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

class InvalidCredentialsException extends AuthenticationException {
  @override
  String get typeName => 'InvalidCredentialsException';

  const InvalidCredentialsException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

class TokenExpiredException extends AuthenticationException {
  final DateTime? expiredAt;

  const TokenExpiredException({
    required super.message,
    this.expiredAt,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() => 'TokenExpiredException: $message${expiredAt != null ? ' (Expired: $expiredAt)' : ''}';
}

class SessionInvalidException extends AuthenticationException {
  @override
  String get typeName => 'SessionInvalidException';

  const SessionInvalidException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

// Validation exceptions
class ValidationException extends AppException {
  final Map<String, List<String>> errors;

  const ValidationException({
    required this.errors,
    String? message,
    super.code,
    super.originalError,
    super.stackTrace,
  }) : super(
          message: message ?? 'Validation failed',
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
    super.code,
    super.originalError,
    super.stackTrace,
  }) : super(
          errors: {
            for (final field in missingFields) field: ['This field is required']
          },
          message: message ?? 'Required fields are missing',
        );

  @override
  String toString() => 'RequiredFieldException: $message - Missing: ${missingFields.join(', ')}';
}

// Data-related exceptions
class DataException extends AppException {
  @override
  String get typeName => 'DataException';

  const DataException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

class NotFoundException extends DataException {
  @override
  String get typeName => 'NotFoundException';

  final String? resourceType;
  final String? resourceId;

  const NotFoundException({
    required super.message,
    this.resourceType,
    this.resourceId,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() => 'NotFoundException: $message${resourceType != null ? ' (Type: $resourceType)' : ''}${resourceId != null ? ' (ID: $resourceId)' : ''}';
}

class DuplicateResourceException extends DataException {
  @override
  String get typeName => 'DuplicateResourceException';

  final String? resourceType;
  final String? duplicateField;

  const DuplicateResourceException({
    required super.message,
    this.resourceType,
    this.duplicateField,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

// Cache exceptions
class CacheException extends AppException {
  @override
  String get typeName => 'CacheException';

  const CacheException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

class CacheMissException extends CacheException {
  @override
  String get typeName => 'CacheMissException';

  final String? cacheKey;

  const CacheMissException({
    required super.message,
    this.cacheKey,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

// Business logic exceptions
class BusinessLogicException extends AppException {
  @override
  String get typeName => 'BusinessLogicException';

  const BusinessLogicException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

class InsufficientPermissionException extends BusinessLogicException {
  @override
  String get typeName => 'InsufficientPermissionException';

  final String? requiredPermission;
  final String? userRole;

  const InsufficientPermissionException({
    required super.message,
    this.requiredPermission,
    this.userRole,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

class ResourceLockedException extends BusinessLogicException {
  final String? lockedBy;
  final DateTime? lockExpiresAt;

  const ResourceLockedException({
    required super.message,
    this.lockedBy,
    this.lockExpiresAt,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

// Configuration exceptions
class ConfigurationException extends AppException {
  @override
  String get typeName => 'ConfigurationException';

  const ConfigurationException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

class MissingConfigurationException extends ConfigurationException {
  final String? configKey;

  const MissingConfigurationException({
    required super.message,
    this.configKey,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}