/// Error Handler Service
///
/// Centralized error handling service that processes exceptions
/// and provides appropriate user feedback and logging.
///
/// Features:
/// - Exception categorization and mapping
/// - User-friendly error messages
/// - Error logging and analytics
/// - Recovery suggestions
/// - Error reporting integration
///
/// Example usage:
/// ```dart
/// final errorHandler = ErrorHandler();
/// final errorInfo = errorHandler.handleError(exception);
/// print(errorInfo.userMessage);
/// ```

import 'dart:io';
import 'package:flutter/foundation.dart';
import '../exceptions/app_exceptions.dart';

/// Error information for display and logging
class ErrorInfo {
  final String title;
  final String message;
  final String userMessage;
  final ErrorType type;
  final String? code;
  final List<String> suggestions;
  final bool isRecoverable;
  final Map<String, dynamic> metadata;

  const ErrorInfo({
    required this.title,
    required this.message,
    required this.userMessage,
    required this.type,
    this.code,
    this.suggestions = const [],
    this.isRecoverable = true,
    this.metadata = const {},
  });

  @override
  String toString() => 'ErrorInfo(title: $title, type: $type, message: $userMessage)';
}

/// Error categories for different handling strategies
enum ErrorType {
  network,
  authentication,
  validation,
  data,
  cache,
  businessLogic,
  configuration,
  unknown,
}

/// Error handling strategies
enum ErrorHandlingStrategy {
  showUserMessage,
  showRetryDialog,
  showLoginForm,
  logOnly,
  reportToAnalytics,
  redirectToSettings,
}

/// Centralized error handler service
class ErrorHandler {
  static ErrorHandler? _instance;
  static ErrorHandler get instance => _instance ??= ErrorHandler._();

  ErrorHandler._();

  /// Handle any exception and return structured error information
  ErrorInfo handleError(
    dynamic exception, {
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    final errorInfo = _createErrorInfo(exception, stackTrace, context);

    // Log the error
    _logError(errorInfo, exception, stackTrace);

    // Report to analytics if needed
    _reportToAnalytics(errorInfo, exception, stackTrace);

    return errorInfo;
  }

  /// Get appropriate handling strategy for an error
  ErrorHandlingStrategy getHandlingStrategy(ErrorInfo errorInfo) {
    switch (errorInfo.type) {
      case ErrorType.network:
        return ErrorHandlingStrategy.showRetryDialog;
      case ErrorType.authentication:
        if (errorInfo is TokenExpiredException) {
          return ErrorHandlingStrategy.showLoginForm;
        }
        return ErrorHandlingStrategy.showUserMessage;
      case ErrorType.validation:
        return ErrorHandlingStrategy.showUserMessage;
      case ErrorType.data:
        if (errorInfo is NotFoundException) {
          return ErrorHandlingStrategy.showUserMessage;
        }
        return ErrorHandlingStrategy.showRetryDialog;
      case ErrorType.cache:
        return ErrorHandlingStrategy.logOnly;
      case ErrorType.businessLogic:
        return ErrorHandlingStrategy.showUserMessage;
      case ErrorType.configuration:
        return ErrorHandlingStrategy.redirectToSettings;
      case ErrorType.unknown:
        return ErrorHandlingStrategy.showUserMessage;
    }
  }

  /// Create error information from exception
  ErrorInfo _createErrorInfo(
    dynamic exception,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  ) {
    if (exception is AppException) {
      return _createAppExceptionInfo(exception, context);
    }

    if (exception is SocketException) {
      return ErrorInfo(
        title: 'Connection Error',
        message: exception.message,
        userMessage: 'Unable to connect to the server. Please check your internet connection.',
        type: ErrorType.network,
        code: 'SOCKET_ERROR',
        suggestions: [
          'Check your internet connection',
          'Try again in a moment',
          'Contact support if the problem persists',
        ],
        metadata: context ?? {},
      );
    }

    if (exception is HttpException) {
      return ErrorInfo(
        title: 'HTTP Error',
        message: exception.message,
        userMessage: 'Server returned an error. Please try again later.',
        type: ErrorType.network,
        code: 'HTTP_ERROR',
        metadata: {
          'statusCode': exception.statusCode,
          ...?context,
        },
      );
    }

    if (exception is FormatException) {
      return ErrorInfo(
        title: 'Data Format Error',
        message: exception.message,
        userMessage: 'The server returned invalid data. Please try again.',
        type: ErrorType.data,
        code: 'FORMAT_ERROR',
        metadata: context ?? {},
      );
    }

    if (exception is TimeoutException) {
      return ErrorInfo(
        title: 'Timeout Error',
        message: exception.message ?? 'Request timed out',
        userMessage: 'The request took too long to complete. Please try again.',
        type: ErrorType.network,
        code: 'TIMEOUT_ERROR',
        suggestions: [
          'Check your internet connection speed',
          'Try again later',
          'Contact support if the problem persists',
        ],
        metadata: {
          'timeout': exception.duration?.inSeconds,
          ...?context,
        },
      );
    }

    // Unknown exception
    return ErrorInfo(
      title: 'Unexpected Error',
      message: exception.toString(),
      userMessage: 'An unexpected error occurred. Please try again or contact support.',
      type: ErrorType.unknown,
      code: 'UNKNOWN_ERROR',
      suggestions: [
        'Try again',
        'Restart the app',
        'Contact support if the problem persists',
      ],
      metadata: context ?? {},
    );
  }

  /// Create error info for custom application exceptions
  ErrorInfo _createAppExceptionInfo(AppException exception, Map<String, dynamic>? context) {
    if (exception is NetworkException) {
      return ErrorInfo(
        title: 'Network Error',
        message: exception.message,
        userMessage: _getNetworkUserMessage(exception),
        type: ErrorType.network,
        code: exception.code ?? 'NETWORK_ERROR',
        suggestions: _getNetworkSuggestions(exception),
        metadata: {
          'statusCode': exception.statusCode,
          'url': exception.url,
          ...?context,
        },
      );
    }

    if (exception is AuthenticationException) {
      return ErrorInfo(
        title: 'Authentication Error',
        message: exception.message,
        userMessage: _getAuthenticationUserMessage(exception),
        type: ErrorType.authentication,
        code: exception.code ?? 'AUTH_ERROR',
        isRecoverable: exception is TokenExpiredException,
        suggestions: _getAuthenticationSuggestions(exception),
        metadata: context ?? {},
      );
    }

    if (exception is ValidationException) {
      return ErrorInfo(
        title: 'Validation Error',
        message: exception.message,
        userMessage: 'Please check your input and try again.',
        type: ErrorType.validation,
        code: exception.code ?? 'VALIDATION_ERROR',
        suggestions: ['Check all required fields', 'Ensure correct format'],
        metadata: {
          'errors': exception.errors,
          ...?context,
        },
      );
    }

    if (exception is DataException) {
      return ErrorInfo(
        title: 'Data Error',
        message: exception.message,
        userMessage: _getDataUserMessage(exception),
        type: ErrorType.data,
        code: exception.code ?? 'DATA_ERROR',
        suggestions: _getDataSuggestions(exception),
        metadata: context ?? {},
      );
    }

    if (exception is CacheException) {
      return ErrorInfo(
        title: 'Cache Error',
        message: exception.message,
        userMessage: 'Data cache error. The app will refresh automatically.',
        type: ErrorType.cache,
        code: exception.code ?? 'CACHE_ERROR',
        isRecoverable: true,
        metadata: context ?? {},
      );
    }

    if (exception is BusinessLogicException) {
      return ErrorInfo(
        title: 'Operation Not Allowed',
        message: exception.message,
        userMessage: exception.message,
        type: ErrorType.businessLogic,
        code: exception.code ?? 'BUSINESS_LOGIC_ERROR',
        suggestions: _getBusinessLogicSuggestions(exception),
        metadata: context ?? {},
      );
    }

    if (exception is ConfigurationException) {
      return ErrorInfo(
        title: 'Configuration Error',
        message: exception.message,
        userMessage: 'App configuration error. Please contact support.',
        type: ErrorType.configuration,
        code: exception.code ?? 'CONFIG_ERROR',
        isRecoverable: false,
        suggestions: ['Restart the app', 'Update the app', 'Contact support'],
        metadata: context ?? {},
      );
    }

    // Fallback for unknown AppException
    return ErrorInfo(
      title: 'Application Error',
      message: exception.message,
      userMessage: 'An application error occurred. Please try again.',
      type: ErrorType.unknown,
      code: exception.code ?? 'APP_ERROR',
      metadata: context ?? {},
    );
  }

  /// Get user-friendly network error messages
  String _getNetworkUserMessage(NetworkException exception) {
    if (exception is ServerException) {
      if (exception.statusCode! >= 500) {
        return 'Server is temporarily unavailable. Please try again later.';
      } else if (exception.statusCode! == 404) {
        return 'The requested resource was not found.';
      } else if (exception.statusCode! == 403) {
        return 'You don\'t have permission to access this resource.';
      }
    }
    if (exception is ConnectionException) {
      return 'Unable to connect to the server. Please check your internet connection.';
    }
    if (exception is TimeoutException) {
      return 'The request took too long to complete. Please try again.';
    }
    return 'A network error occurred. Please try again.';
  }

  /// Get network error suggestions
  List<String> _getNetworkSuggestions(NetworkException exception) {
    if (exception is ServerException) {
      if (exception.statusCode! >= 500) {
        return ['Try again later', 'Contact support if the problem persists'];
      }
    }
    return [
      'Check your internet connection',
      'Try again in a moment',
      'Contact support if the problem persists',
    ];
  }

  /// Get user-friendly authentication error messages
  String _getAuthenticationUserMessage(AuthenticationException exception) {
    if (exception is InvalidCredentialsException) {
      return 'Invalid username or password. Please try again.';
    }
    if (exception is TokenExpiredException) {
      return 'Your session has expired. Please log in again.';
    }
    if (exception is SessionInvalidException) {
      return 'Your session is invalid. Please log in again.';
    }
    return 'Authentication failed. Please log in again.';
  }

  /// Get authentication error suggestions
  List<String> _getAuthenticationSuggestions(AuthenticationException exception) {
    if (exception is InvalidCredentialsException) {
      return ['Check your username and password', 'Reset your password if needed'];
    }
    if (exception is TokenExpiredException) {
      return ['Please log in again to continue'];
    }
    return ['Please log in again', 'Contact support if the problem persists'];
  }

  /// Get user-friendly data error messages
  String _getDataUserMessage(DataException exception) {
    if (exception is NotFoundException) {
      return 'The requested ${exception.resourceType ?? 'item'} was not found.';
    }
    if (exception is DuplicateResourceException) {
      return 'This ${exception.resourceType ?? 'item'} already exists.';
    }
    return 'A data error occurred. Please try again.';
  }

  /// Get data error suggestions
  List<String> _getDataSuggestions(DataException exception) {
    if (exception is NotFoundException) {
      return ['Check if the item exists', 'Refresh the page', 'Contact support'];
    }
    if (exception is DuplicateResourceException) {
      return ['Use a different value', 'Check existing items'];
    }
    return ['Try again', 'Refresh the page', 'Contact support if needed'];
  }

  /// Get business logic error suggestions
  List<String> _getBusinessLogicSuggestions(BusinessLogicException exception) {
    if (exception is InsufficientPermissionException) {
      return ['Contact an administrator', 'Check your permissions'];
    }
    if (exception is ResourceLockedException) {
      return ['Try again later', 'Contact the person who locked the resource'];
    }
    return ['Check your input', 'Contact support if needed'];
  }

  /// Log error information
  void _logError(ErrorInfo errorInfo, dynamic exception, StackTrace? stackTrace) {
    if (kDebugMode) {
      print('=== ERROR LOG ===');
      print('Title: ${errorInfo.title}');
      print('Message: ${errorInfo.message}');
      print('User Message: ${errorInfo.userMessage}');
      print('Type: ${errorInfo.type}');
      print('Code: ${errorInfo.code}');
      print('Suggestions: ${errorInfo.suggestions}');
      print('Metadata: ${errorInfo.metadata}');
      print('Exception: $exception');
      if (stackTrace != null) {
        print('Stack Trace: $stackTrace');
      }
      print('================');
    }
  }

  /// Report error to analytics (placeholder for analytics integration)
  void _reportToAnalytics(ErrorInfo errorInfo, dynamic exception, StackTrace? stackTrace) {
    // Placeholder for analytics integration
    // In a real app, you would send error data to services like:
    // - Firebase Crashlytics
    // - Sentry
    // - Custom analytics

    if (kDebugMode) {
      print('Analytics: Error reported - ${errorInfo.title}');
    }
  }

  /// Reset error handler instance (useful for testing)
  static void reset() {
    _instance = null;
  }
}