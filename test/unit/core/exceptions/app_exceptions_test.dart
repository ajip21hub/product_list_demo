/// App Exceptions Tests
///
/// Unit tests for custom exception classes to ensure proper
/// error handling, message formatting, and type safety.
///
/// Test Coverage:
/// - Exception creation and properties
/// - Error message formatting
/// - Type safety and inheritance
/// - toString() implementations
///
/// Test Cases:
/// - ✅ NetworkException creation
/// - ✅ AuthenticationException creation
/// - ✅ ValidationException creation
/// - ✅ Exception hierarchy validation
/// - ✅ Error message formatting

import 'package:flutter_test/flutter_test.dart';

import '../../../../lib/core/exceptions/app_exceptions.dart';

void main() {
  group('AppException Base Class', () {
    test('should create basic AppException with message', () {
      // Arrange
      const message = 'Test error message';
      const code = 'TEST_ERROR';

      // Act
      final exception = TestAppException(message: message, code: code);

      // Assert
      expect(exception.message, message);
      expect(exception.code, code);
      expect(exception.toString(), 'AppException: $message (Code: $code)');
    });

    test('should create AppException without code', () {
      // Arrange
      const message = 'Test error message';

      // Act
      final exception = TestAppException(message: message);

      // Assert
      expect(exception.message, message);
      expect(exception.code, null);
      expect(exception.toString(), 'AppException: $message');
    });

    test('should handle original error and stack trace', () {
      // Arrange
      const message = 'Test error message';
      final originalError = Exception('Original error');
      final stackTrace = StackTrace.current;

      // Act
      final exception = TestAppException(
        message: message,
        originalError: originalError,
        stackTrace: stackTrace,
      );

      // Assert
      expect(exception.originalError, originalError);
      expect(exception.stackTrace, stackTrace);
    });
  });

  group('NetworkException', () {
    test('should create NetworkException with basic parameters', () {
      // Arrange
      const message = 'Network connection failed';
      const code = 'NETWORK_ERROR';

      // Act
      final exception = NetworkException(message: message, code: code);

      // Assert
      expect(exception.message, message);
      expect(exception.code, code);
      expect(exception.statusCode, null);
      expect(exception.url, null);
      expect(exception.toString(), 'NetworkException: $message (Code: $code)');
    });

    test('should create NetworkException with status code and URL', () {
      // Arrange
      const message = 'Server error';
      const statusCode = 500;
      const url = 'https://example.com/api';

      // Act
      final exception = NetworkException(
        message: message,
        statusCode: statusCode,
        url: url,
      );

      // Assert
      expect(exception.message, message);
      expect(exception.statusCode, statusCode);
      expect(exception.url, url);
      expect(exception.toString(),
             'NetworkException: $message (Status: $statusCode) (URL: $url)');
    });

    test('should create NetworkException with original error', () {
      // Arrange
      const message = 'Network timeout';
      final originalError = TimeoutException('Request timed out', const Duration(seconds: 30));

      // Act
      final exception = NetworkException(
        message: message,
        originalError: originalError,
      );

      // Assert
      expect(exception.message, message);
      expect(exception.originalError, originalError);
    });
  });

  group('ServerException', () {
    test('should create ServerException with required parameters', () {
      // Arrange
      const message = 'Internal server error';
      const statusCode = 500;
      const url = 'https://example.com/api';

      // Act
      final exception = ServerException(
        message: message,
        statusCode: statusCode,
        url: url,
      );

      // Assert
      expect(exception.message, message);
      expect(exception.statusCode, statusCode);
      expect(exception.url, url);
      expect(exception.toString(),
             'ServerException: $message (Status: $statusCode) (URL: $url)');
    });

    test('should inherit from NetworkException', () {
      // Arrange
      const message = 'Server error';
      const statusCode = 404;

      // Act
      final exception = ServerException(
        message: message,
        statusCode: statusCode,
      );

      // Assert
      expect(exception, isA<NetworkException>());
      expect(exception.statusCode, statusCode);
    });
  });

  group('TimeoutException', () {
    test('should create TimeoutException with duration', () {
      // Arrange
      const message = 'Request timed out';
      const timeout = Duration(seconds: 30);

      // Act
      final exception = TimeoutException(
        message: message,
        timeout: timeout,
      );

      // Assert
      expect(exception.message, message);
      expect(exception.timeout, timeout);
      expect(exception.toString(), 'TimeoutException: $message (Timeout: 30s)');
    });

    test('should inherit from NetworkException', () {
      // Arrange
      const message = 'Connection timeout';
      const timeout = Duration(minutes: 1);

      // Act
      final exception = TimeoutException(
        message: message,
        timeout: timeout,
      );

      // Assert
      expect(exception, isA<NetworkException>());
      expect(exception.timeout, timeout);
    });
  });

  group('ConnectionException', () {
    test('should create ConnectionException', () {
      // Arrange
      const message = 'No internet connection';
      const url = 'https://example.com/api';

      // Act
      final exception = ConnectionException(
        message: message,
        url: url,
      );

      // Assert
      expect(exception.message, message);
      expect(exception.url, url);
      expect(exception, isA<NetworkException>());
    });
  });

  group('AuthenticationException', () {
    test('should create AuthenticationException with message', () {
      // Arrange
      const message = 'Invalid credentials';

      // Act
      final exception = AuthenticationException(message: message);

      // Assert
      expect(exception.message, message);
      expect(exception.toString(), 'AuthenticationException: $message');
    });

    test('should create AuthenticationException with code', () {
      // Arrange
      const message = 'Token expired';
      const code = 'TOKEN_EXPIRED';

      // Act
      final exception = AuthenticationException(
        message: message,
        code: code,
      );

      // Assert
      expect(exception.message, message);
      expect(exception.code, code);
    });
  });

  group('InvalidCredentialsException', () {
    test('should create InvalidCredentialsException', () {
      // Arrange
      const message = 'Username or password incorrect';

      // Act
      final exception = InvalidCredentialsException(message: message);

      // Assert
      expect(exception.message, message);
      expect(exception, isA<AuthenticationException>());
    });
  });

  group('TokenExpiredException', () {
    test('should create TokenExpiredException with expiry time', () {
      // Arrange
      const message = 'Token has expired';
      final expiredAt = DateTime.now().subtract(const Duration(hours: 1));

      // Act
      final exception = TokenExpiredException(
        message: message,
        expiredAt: expiredAt,
      );

      // Assert
      expect(exception.message, message);
      expect(exception.expiredAt, expiredAt);
      expect(exception, isA<AuthenticationException>());
    });

    test('should format toString with expiry time', () {
      // Arrange
      const message = 'Token expired';
      final expiredAt = DateTime(2023, 1, 1, 12, 0, 0);

      // Act
      final exception = TokenExpiredException(
        message: message,
        expiredAt: expiredAt,
      );

      // Assert
      expect(exception.toString(),
             contains('TokenExpiredException: $message'));
      expect(exception.toString(), contains('Expired: $expiredAt'));
    });
  });

  group('ValidationException', () {
    test('should create ValidationException with errors', () {
      // Arrange
      const message = 'Validation failed';
      const errors = {
        'email': ['Invalid email format'],
        'password': ['Password too short'],
      };

      // Act
      final exception = ValidationException(
        errors: errors,
        message: message,
      );

      // Assert
      expect(exception.message, message);
      expect(exception.errors, errors);
    });

    test('should format toString with error details', () {
      // Arrange
      const errors = {
        'field1': ['Error 1', 'Error 2'],
        'field2': ['Error 3'],
      };

      // Act
      final exception = ValidationException(errors: errors);

      // Assert
      final result = exception.toString();
      expect(result, contains('ValidationException:'));
      expect(result, contains('field1: Error 1, Error 2'));
      expect(result, contains('field2: Error 3'));
    });

    test('should use default message when not provided', () {
      // Arrange
      const errors = {'field': ['Error']};

      // Act
      final exception = ValidationException(errors: errors);

      // Assert
      expect(exception.message, 'Validation failed');
    });
  });

  group('RequiredFieldException', () {
    test('should create RequiredFieldException with missing fields', () {
      // Arrange
      const missingFields = ['email', 'password', 'name'];

      // Act
      final exception = RequiredFieldException(
        missingFields: missingFields,
        message: 'Required fields missing',
      );

      // Assert
      expect(exception.missingFields, missingFields);
      expect(exception.message, 'Required fields missing');
      expect(exception.errors['email'], ['This field is required']);
      expect(exception.errors['password'], ['This field is required']);
      expect(exception.errors['name'], ['This field is required']);
      expect(exception, isA<ValidationException>());
    });

    test('should format toString with missing fields', () {
      // Arrange
      const missingFields = ['email', 'password'];

      // Act
      final exception = RequiredFieldException(missingFields: missingFields);

      // Assert
      expect(exception.toString(),
             'RequiredFieldException: Required fields are missing - Missing: email, password');
    });

    test('should use default message when not provided', () {
      // Arrange
      const missingFields = ['field'];

      // Act
      final exception = RequiredFieldException(missingFields: missingFields);

      // Assert
      expect(exception.message, 'Required fields are missing');
    });
  });

  group('DataException', () {
    test('should create DataException', () {
      // Arrange
      const message = 'Data processing error';

      // Act
      final exception = DataException(message: message);

      // Assert
      expect(exception.message, message);
      expect(exception.toString(), 'DataException: $message');
    });
  });

  group('NotFoundException', () {
    test('should create NotFoundException with resource details', () {
      // Arrange
      const message = 'Resource not found';
      const resourceType = 'Product';
      const resourceId = '123';

      // Act
      final exception = NotFoundException(
        message: message,
        resourceType: resourceType,
        resourceId: resourceId,
      );

      // Assert
      expect(exception.message, message);
      expect(exception.resourceType, resourceType);
      expect(exception.resourceId, resourceId);
      expect(exception, isA<DataException>());
    });

    test('should format toString with resource details', () {
      // Arrange
      const message = 'Not found';
      const resourceType = 'User';
      const resourceId = '456';

      // Act
      final exception = NotFoundException(
        message: message,
        resourceType: resourceType,
        resourceId: resourceId,
      );

      // Assert
      expect(exception.toString(),
             'NotFoundException: $message (Type: $resourceType) (ID: $resourceId)');
    });
  });

  group('DuplicateResourceException', () {
    test('should create DuplicateResourceException', () {
      // Arrange
      const message = 'Resource already exists';
      const resourceType = 'Email';
      const duplicateField = 'email_address';

      // Act
      final exception = DuplicateResourceException(
        message: message,
        resourceType: resourceType,
        duplicateField: duplicateField,
      );

      // Assert
      expect(exception.message, message);
      expect(exception.resourceType, resourceType);
      expect(exception.duplicateField, duplicateField);
      expect(exception, isA<DataException>());
    });
  });

  group('CacheException', () {
    test('should create CacheException', () {
      // Arrange
      const message = 'Cache access failed';

      // Act
      final exception = CacheException(message: message);

      // Assert
      expect(exception.message, message);
      expect(exception.toString(), 'CacheException: $message');
    });
  });

  group('CacheMissException', () {
    test('should create CacheMissException with cache key', () {
      // Arrange
      const message = 'Cache miss';
      const cacheKey = 'user_123';

      // Act
      final exception = CacheMissException(
        message: message,
        cacheKey: cacheKey,
      );

      // Assert
      expect(exception.message, message);
      expect(exception.cacheKey, cacheKey);
      expect(exception, isA<CacheException>());
    });
  });

  group('BusinessLogicException', () {
    test('should create BusinessLogicException', () {
      // Arrange
      const message = 'Operation not allowed';

      // Act
      final exception = BusinessLogicException(message: message);

      // Assert
      expect(exception.message, message);
      expect(exception.toString(), 'BusinessLogicException: $message');
    });
  });

  group('InsufficientPermissionException', () {
    test('should create InsufficientPermissionException', () {
      // Arrange
      const message = 'Permission denied';
      const requiredPermission = 'admin_access';
      const userRole = 'user';

      // Act
      final exception = InsufficientPermissionException(
        message: message,
        requiredPermission: requiredPermission,
        userRole: userRole,
      );

      // Assert
      expect(exception.message, message);
      expect(exception.requiredPermission, requiredPermission);
      expect(exception.userRole, userRole);
      expect(exception, isA<BusinessLogicException>());
    });
  });

  group('ResourceLockedException', () {
    test('should create ResourceLockedException', () {
      // Arrange
      const message = 'Resource is locked';
      const lockedBy = 'user123';
      final lockExpiresAt = DateTime.now().add(const Duration(hours: 1));

      // Act
      final exception = ResourceLockedException(
        message: message,
        lockedBy: lockedBy,
        lockExpiresAt: lockExpiresAt,
      );

      // Assert
      expect(exception.message, message);
      expect(exception.lockedBy, lockedBy);
      expect(exception.lockExpiresAt, lockExpiresAt);
      expect(exception, isA<BusinessLogicException>());
    });
  });

  group('ConfigurationException', () {
    test('should create ConfigurationException', () {
      // Arrange
      const message = 'Configuration missing';

      // Act
      final exception = ConfigurationException(message: message);

      // Assert
      expect(exception.message, message);
      expect(exception.toString(), 'ConfigurationException: $message');
    });
  });

  group('MissingConfigurationException', () {
    test('should create MissingConfigurationException', () {
      // Arrange
      const message = 'Required configuration missing';
      const configKey = 'API_BASE_URL';

      // Act
      final exception = MissingConfigurationException(
        message: message,
        configKey: configKey,
      );

      // Assert
      expect(exception.message, message);
      expect(exception.configKey, configKey);
      expect(exception, isA<ConfigurationException>());
    });
  });
}

/// Test exception class for testing the base class
class TestAppException extends AppException {
  const TestAppException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}