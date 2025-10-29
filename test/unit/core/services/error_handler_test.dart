/// Error Handler Service Tests
///
/// Unit tests for the centralized error handling service to ensure
/// proper error processing, user message generation, and
/// handling strategy determination.
///
/// Test Coverage:
/// - Exception categorization
/// - User message generation
/// - Error handling strategies
/// - Error information creation
/// - Logging and analytics integration
///
/// Test Cases:
/// - ✅ Network error handling
/// - ✅ Authentication error handling
/// - ✅ Validation error handling
/// - ✅ Unknown error handling
/// - ✅ Error strategy determination

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';

import '../../../../lib/core/services/error_handler.dart';
import '../../../../lib/core/exceptions/app_exceptions.dart';

void main() {
  group('ErrorHandler Service Tests', () {
    setUp(() {
      // Reset error handler for each test
      ErrorHandler.reset();
    });

    tearDown(() {
      ErrorHandler.reset();
    });

    group('Error Categorization', () {
      test('should categorize NetworkException correctly', () {
        // Arrange
        final networkException = NetworkException(
          message: 'Connection failed',
          statusCode: 500,
        );

        // Act
        final errorInfo = ErrorHandler.instance.handleError(networkException);

        // Assert
        expect(errorInfo.title, 'Network Error');
        expect(errorInfo.type, ErrorType.network);
        expect(errorInfo.userMessage, contains('server temporarily unavailable'));
        expect(errorInfo.code, 'NETWORK_ERROR');
      });

      test('should categorize AuthenticationException correctly', () {
        // Arrange
        final authException = InvalidCredentialsException(
          message: 'Invalid credentials',
        );

        // Act
        final errorInfo = ErrorHandler.instance.handleError(authException);

        // Assert
        expect(errorInfo.title, 'Authentication Error');
        expect(errorInfo.type, ErrorType.authentication);
        expect(errorInfo.userMessage, 'Invalid username or password. Please try again.');
        expect(errorInfo.suggestions, contains('Check your username and password'));
      });

      test('should categorize ValidationException correctly', () {
        // Arrange
        const validationException = ValidationException(
          errors: {
            'email': ['Invalid email format'],
            'password': ['Password too short'],
          },
        );

        // Act
        final errorInfo = ErrorHandler.instance.handleError(validationException);

        // Assert
        expect(errorInfo.title, 'Validation Error');
        expect(errorInfo.type, ErrorType.validation);
        expect(errorInfo.userMessage, 'Please check your input and try again.');
        expect(errorInfo.suggestions, contains('Check all required fields'));
      });

      test('should categorize DataException correctly', () {
        // Arrange
        final dataException = NotFoundException(
          message: 'Product not found',
          resourceType: 'Product',
          resourceId: '123',
        );

        // Act
        final errorInfo = ErrorHandler.instance.handleError(dataException);

        // Assert
        expect(errorInfo.title, 'Data Error');
        expect(errorInfo.type, ErrorType.data);
        expect(errorInfo.userMessage, 'The requested Product was not found.');
        expect(errorInfo.suggestions, contains('Check if the item exists'));
      });

      test('should categorize CacheException correctly', () {
        // Arrange
        const cacheException = CacheMissException(
          message: 'Cache miss',
          cacheKey: 'user_123',
        );

        // Act
        final errorInfo = ErrorHandler.instance.handleError(cacheException);

        // Assert
        expect(errorInfo.title, 'Cache Error');
        expect(errorInfo.type, ErrorType.cache);
        expect(errorInfo.userMessage, 'Data cache error. The app will refresh automatically.');
        expect(errorInfo.isRecoverable, true);
      });

      test('should categorize BusinessLogicException correctly', () {
        // Arrange
        const businessException = InsufficientPermissionException(
          message: 'Permission denied',
          requiredPermission: 'admin_access',
          userRole: 'user',
        );

        // Act
        final errorInfo = ErrorHandler.instance.handleError(businessException);

        // Assert
        expect(errorInfo.title, 'Operation Not Allowed');
        expect(errorInfo.type, ErrorType.businessLogic);
        expect(errorInfo.userMessage, 'Permission denied');
        expect(errorInfo.suggestions, contains('Contact an administrator'));
      });

      test('should categorize ConfigurationException correctly', () {
        // Arrange
        const configException = MissingConfigurationException(
          message: 'API URL not configured',
          configKey: 'API_BASE_URL',
        );

        // Act
        final errorInfo = ErrorHandler.instance.handleError(configException);

        // Assert
        expect(errorInfo.title, 'Configuration Error');
        expect(errorInfo.type, ErrorType.configuration);
        expect(errorInfo.userMessage, 'App configuration error. Please contact support.');
        expect(errorInfo.isRecoverable, false);
      });

      test('should handle unknown exceptions correctly', () {
        // Arrange
        final unknownException = Exception('Unexpected error');

        // Act
        final errorInfo = ErrorHandler.instance.handleError(unknownException);

        // Assert
        expect(errorInfo.title, 'Unexpected Error');
        expect(errorInfo.type, ErrorType.unknown);
        expect(errorInfo.userMessage, 'An unexpected error occurred. Please try again or contact support.');
        expect(errorInfo.suggestions, contains('Try again'));
      });
    });

    group('Error Message Generation', () {
      test('should generate appropriate network error messages', () {
        // Test different network error scenarios
        final testCases = [
          {
            'exception': const ServerException(
              message: 'Internal Server Error',
              statusCode: 500,
            ),
            'expectedMessage': 'Server is temporarily unavailable',
          },
          {
            'exception': const ServerException(
              message: 'Not Found',
              statusCode: 404,
            ),
            'expectedMessage': 'The requested resource was not found.',
          },
          {
            'exception': const ServerException(
              message: 'Forbidden',
              statusCode: 403,
            ),
            'expectedMessage': 'You don\'t have permission to access this resource.',
          },
          {
            'exception': const ConnectionException(
              message: 'No connection',
            ),
            'expectedMessage': 'Unable to connect to the server',
          },
          {
            'exception': const TimeoutException(
              message: 'Request timeout',
              timeout: Duration(seconds: 30),
            ),
            'expectedMessage': 'The request took too long to complete',
          },
        ];

        for (final testCase in testCases) {
          // Act
          final errorInfo = ErrorHandler.instance.handleError(testCase['exception']);

          // Assert
          expect(errorInfo.userMessage, contains(testCase['expectedMessage']),
              reason: 'Failed for ${testCase['exception'].runtimeType}');
        }
      });

      test('should generate appropriate authentication error messages', () {
        // Test different authentication error scenarios
        final testCases = [
          {
            'exception': const InvalidCredentialsException(
              message: 'Invalid credentials',
            ),
            'expectedMessage': 'Invalid username or password',
          },
          {
            'exception': TokenExpiredException(
              message: 'Token expired',
              expiredAt: DateTime.now().subtract(const Duration(hours: 2)),
            ),
            'expectedMessage': 'Your session has expired',
          },
          {
            'exception': const SessionInvalidException(
              message: 'Session invalid',
            ),
            'expectedMessage': 'Your session is invalid',
          },
        ];

        for (final testCase in testCases) {
          // Act
          final errorInfo = ErrorHandler.instance.handleError(testCase['exception']);

          // Assert
          expect(errorInfo.userMessage, contains(testCase['expectedMessage']),
              reason: 'Failed for ${testCase['exception'].runtimeType}');
        }
      });

      test('should generate appropriate data error messages', () {
        // Test different data error scenarios
        final testCases = [
          {
            'exception': NotFoundException(
              message: 'User not found',
              resourceType: 'User',
              resourceId: '123',
            ),
            'expectedMessage': 'The requested User was not found.',
          },
          {
            'exception': DuplicateResourceException(
              message: 'Email already exists',
              resourceType: 'Email',
              duplicateField: 'email_address',
            ),
            'expectedMessage': 'This Email already exists',
          },
        ];

        for (final testCase in testCases) {
          // Act
          final errorInfo = ErrorHandler.instance.handleError(testCase['exception']);

          // Assert
          expect(errorInfo.userMessage, contains(testCase['expectedMessage']),
              reason: 'Failed for ${testCase['exception'].runtimeType}');
        }
      });
    });

    group('Error Handling Strategy Determination', () {
      test('should return retry dialog for network errors', () {
        // Arrange
        final networkException = NetworkException(message: 'Network error');

        // Act
        final errorInfo = ErrorHandler.instance.handleError(networkException);
        final strategy = ErrorHandler.instance.getHandlingStrategy(errorInfo);

        // Assert
        expect(strategy, ErrorHandlingStrategy.showRetryDialog);
      });

      test('should return login form for token expired', () {
        // Arrange
        final tokenExpired = TokenExpiredException(
          message: 'Token expired',
          expiredAt: DateTime.now().subtract(const Duration(hours: 1)),
        );

        // Act
        final errorInfo = ErrorHandler.instance.handleError(tokenExpired);
        final strategy = ErrorHandler.instance.getHandlingStrategy(errorInfo);

        // Assert
        expect(strategy, ErrorHandlingStrategy.showLoginForm);
      });

      test('should return user message for other auth errors', () {
        // Arrange
        final authError = InvalidCredentialsException(message: 'Invalid credentials');

        // Act
        final errorInfo = ErrorHandler.instance.handleError(authError);
        final strategy = ErrorHandler.instance.getHandlingStrategy(errorInfo);

        // Assert
        expect(strategy, ErrorHandlingStrategy.showUserMessage);
      });

      test('should return user message for validation errors', () {
        // Arrange
        const validationError = ValidationException(
          errors: {'field': ['Error']},
        );

        // Act
        final errorInfo = ErrorHandler.instance.handleError(validationError);
        final strategy = ErrorHandler.instance.getHandlingStrategy(errorInfo);

        // Assert
        expect(strategy, ErrorHandlingStrategy.showUserMessage);
      });

      test('should return retry dialog for not found errors', () {
        // Arrange
        final notFoundError = NotFoundException(
          message: 'Not found',
          resourceType: 'Product',
        );

        // Act
        final errorInfo = ErrorHandler.instance.handleError(notFoundError);
        final strategy = ErrorHandler.instance.getHandlingStrategy(errorInfo);

        // Assert
        expect(strategy, ErrorHandlingStrategy.showRetryDialog);
      });

      test('should return log only for cache errors', () {
        // Arrange
        const cacheError = CacheException(message: 'Cache error');

        // Act
        final errorInfo = ErrorHandler.instance.handleError(cacheError);
        final strategy = ErrorHandler.instance.getHandlingStrategy(errorInfo);

        // Assert
        expect(strategy, ErrorHandlingStrategy.logOnly);
      });

      test('should return redirect to settings for configuration errors', () {
        // Arrange
        const configError = ConfigurationException(message: 'Config error');

        // Act
        final errorInfo = ErrorHandler.instance.handleError(configError);
        final strategy = ErrorHandler.instance.getHandlingStrategy(errorInfo);

        // Assert
        expect(strategy, ErrorHandlingStrategy.redirectToSettings);
      });

      test('should return user message for unknown errors', () {
        // Arrange
        final unknownError = Exception('Unknown error');

        // Act
        final errorInfo = ErrorHandler.instance.handleError(unknownError);
        final strategy = ErrorHandler.instance.getHandlingStrategy(errorInfo);

        // Assert
        expect(strategy, ErrorHandlingStrategy.showUserMessage);
      });
    });

    group('Error Information Creation', () {
      test('should include metadata in error info', () {
        // Arrange
        final context = {'userId': '123', 'action': 'load_products'};
        final networkError = NetworkException(
          message: 'Network error',
          statusCode: 500,
          url: 'https://example.com/api/products',
        );

        // Act
        final errorInfo = ErrorHandler.instance.handleError(
          networkError,
          context: context,
        );

        // Assert
        expect(errorInfo.metadata, containsPair('userId', '123'));
        expect(errorInfo.metadata, containsPair('action', 'load_products'));
        expect(errorInfo.metadata, containsPair('statusCode', 500));
        expect(errorInfo.metadata, containsPair('url', 'https://example.com/api/products'));
      });

      test('should include suggestions for recoverable errors', () {
        // Arrange
        final networkError = ConnectionException(message: 'Connection failed');

        // Act
        final errorInfo = ErrorHandler.instance.handleError(networkError);

        // Assert
        expect(errorInfo.suggestions, isNotEmpty);
        expect(errorInfo.suggestions, contains('Check your internet connection'));
        expect(errorInfo.suggestions, contains('Try again in a moment'));
        expect(errorInfo.isRecoverable, true);
      });

      test('should set isRecoverable to false for non-recoverable errors', () {
        // Arrange
        const configError = ConfigurationException(message: 'Config error');

        // Act
        final errorInfo = ErrorHandler.instance.handleError(configError);

        // Assert
        expect(errorInfo.isRecoverable, false);
      });
    });

    group('Error Logging and Analytics', () {
      test('should log error information in debug mode', () {
        // Arrange
        debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
        final networkError = NetworkException(message: 'Test error');

        // Capture console output
        var capturedLogs = <String>[];
        final originalPrint = debugPrint;
        debugPrint = (String? message) {
          if (message != null) capturedLogs.add(message);
        };

        // Act
        final errorInfo = ErrorHandler.instance.handleError(networkError);

        // Restore original print
        debugPrint = originalPrint;

        // Assert
        expect(capturedLogs, isNotEmpty);
        expect(capturedLogs.any((log) => log.contains('=== ERROR LOG ===')), true);
        expect(capturedLogs.any((log) => log.contains('Title: ${errorInfo.title}')), true);
        expect(capturedLogs.any((log) => log.contains('Type: ${errorInfo.type}')), true);

        // Clean up
        debugDefaultTargetPlatformOverride = null;
      });

      test('should report to analytics in debug mode', () {
        // Arrange
        debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
        final networkError = NetworkException(message: 'Test error');

        // Capture analytics calls
        var capturedAnalytics = <String>[];
        final originalPrint = debugPrint;
        debugPrint = (String? message) {
          if (message != null && message.contains('Analytics:')) {
            capturedAnalytics.add(message);
          }
        };

        // Act
        final errorInfo = ErrorHandler.instance.handleError(networkError);

        // Restore original print
        debugPrint = originalPrint;

        // Assert
        expect(capturedAnalytics, isNotEmpty);
        expect(capturedAnalytics.any((log) => log.contains('Analytics: Error reported')), true);

        // Clean up
        debugDefaultTargetPlatformOverride = null;
      });
    });

    group('Edge Cases', () {
      test('should handle null context gracefully', () {
        // Arrange
        final networkError = NetworkException(message: 'Test error');

        // Act
        final errorInfo = ErrorHandler.instance.handleError(networkError, context: null);

        // Assert
        expect(errorInfo.metadata, isEmpty);
      });

      test('should handle empty context gracefully', () {
        // Arrange
        final networkError = NetworkException(message: 'Test error');

        // Act
        final errorInfo = ErrorHandler.instance.handleError(networkError, context: {});

        // Assert
        expect(errorInfo.metadata, isEmpty);
      });

      test('should handle very long error messages', () {
        // Arrange
        final longMessage = 'Error' * 100; // 500 character message
        final networkError = NetworkException(message: longMessage);

        // Act
        final errorInfo = ErrorHandler.instance.handleError(networkError);

        // Assert
        expect(errorInfo.message, longMessage);
        expect(errorInfo.userMessage, isA<String>());
        expect(errorInfo.userMessage.length, lessThan(200)); // User message should be reasonable length
      });

      test('should handle null stack trace gracefully', () {
        // Arrange
        final networkError = NetworkException(
          message: 'Test error',
          stackTrace: null,
        );

        // Act
        final errorInfo = ErrorHandler.instance.handleError(networkError);

        // Assert
        expect(errorInfo.title, 'Network Error');
        expect(errorInfo.userMessage, isA<String>());
      });

      test('should create ErrorInfo for complex nested exceptions', () {
        // Arrange
        final originalError = Exception('Original error');
        final wrappedError = NetworkException(
          message: 'Wrapped error',
          originalError: originalError,
        );

        // Act
        final errorInfo = ErrorHandler.instance.handleError(wrappedError);

        // Assert
        expect(errorInfo.title, 'Network Error');
        expect(errorInfo.userMessage, isA<String>());
        expect(errorInfo.metadata, containsPair('originalError', originalError));
      });
    });

    group('Instance Management', () {
      test('should provide singleton instance', () {
        // Act
        final instance1 = ErrorHandler.instance;
        final instance2 = ErrorHandler.instance;

        // Assert
        expect(identical(instance1, instance2), true);
      });

      test('should reset instance correctly', () {
        // Act
        final beforeReset = ErrorHandler.instance;
        ErrorHandler.reset();
        final afterReset = ErrorHandler.instance;

        // Assert
        expect(identical(beforeReset, afterReset), false);
      });

      test('should create new instance after reset', () {
        // Arrange
        ErrorHandler.reset();

        // Act
        final instance1 = ErrorHandler.instance;
        ErrorHandler.reset();
        final instance2 = ErrorHandler.instance;

        // Assert
        expect(identical(instance1, instance2), false);
        expect(instance1, isA<ErrorHandler>());
        expect(instance2, isA<ErrorHandler>());
      });
    });
  });
}