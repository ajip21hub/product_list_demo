/// Enhanced Result Type with Error Handling Integration
///
/// A functional approach to error handling that integrates with the
/// custom exception system. This provides type-safe error handling
/// and makes the code more robust and maintainable.
///
/// Features:
/// - Type-safe success and error handling
/// - Integration with custom exception hierarchy
/// - Functional programming patterns (fold, map, etc.)
/// - Async support
/// - Chaining operations
///
/// Example usage:
/// ```dart
/// final result = await repository.getUser(id);
/// result.fold(
///   onFailure: (error) => print('Error: ${error.message}'),
///   onSuccess: (user) => print('User: ${user.name}'),
/// );
/// ```

import '../exceptions/app_exceptions.dart';
import '../services/error_handler.dart';

/// Enhanced Result class with better error handling
class Result<T> {
  final T? _data;
  final AppException? _error;
  final bool _isSuccess;

  const Result._({
    T? data,
    AppException? error,
    required bool isSuccess,
  })  : _data = data,
        _error = error,
        _isSuccess = isSuccess;

  /// Create a successful result
  factory Result.success(T data) => Result._(data: data, isSuccess: true);

  /// Create a failure result
  factory Result.failure(AppException error) => Result._(error: error, isSuccess: false);

  /// Create a failure result from any exception
  factory Result.failureFromException(dynamic exception, {String? message}) {
    final appException = exception is AppException
        ? exception
        : AppException(
            message: message ?? exception.toString(),
            originalError: exception,
          );
    return Result.failure(appException);
  }

  /// Check if result is successful
  bool get isSuccess => _isSuccess;

  /// Check if result is a failure
  bool get isFailure => !_isSuccess;

  /// Get data if successful, throws if failure
  T get dataOrThrow {
    if (_isSuccess && _data != null) {
      return _data!;
    }
    throw _error ?? AppException(message: 'No data available');
  }

  /// Get data if successful, null if failure
  T? get dataOrNull => _isSuccess ? _data : null;

  /// Get error if failure, null if successful
  AppException? get errorOrNull => _isFailure ? _error : null;

  /// Get error message if failure, null if successful
  String? get errorMessageOrNull => _isFailure ? _error?.message : null;

  /// Transform data if successful
  Result<R> map<R>(R Function(T data) transform) {
    if (_isSuccess && _data != null) {
      try {
        final newData = transform(_data!);
        return Result.success(newData);
      } catch (e, stackTrace) {
        return Result.failureFromException(e, stackTrace: stackTrace);
      }
    } else {
      return Result.failure(_error!);
    }
  }

  /// Transform result with async function
  Future<Result<R>> mapAsync<R>(Future<R> Function(T data) transform) async {
    if (_isSuccess && _data != null) {
      try {
        final newData = await transform(_data!);
        return Result.success(newData);
      } catch (e, stackTrace) {
        return Result.failureFromException(e, stackTrace: stackTrace);
      }
    } else {
      return Result.failure(_error!);
    }
  }

  /// Apply function to data if successful, return result of function
  Result<R> flatMap<R>(Result<R> Function(T data) transform) {
    if (_isSuccess && _data != null) {
      try {
        return transform(_data!);
      } catch (e, stackTrace) {
        return Result.failureFromException(e, stackTrace: stackTrace);
      }
    } else {
      return Result.failure(_error!);
    }
  }

  /// Apply async function to data if successful, return result of function
  Future<Result<R>> flatMapAsync<R>(Future<Result<R>> Function(T data) transform) async {
    if (_isSuccess && _data != null) {
      try {
        return await transform(_data!);
      } catch (e, stackTrace) {
        return Result.failureFromException(e, stackTrace: stackTrace);
      }
    } else {
      return Result.failure(_error!);
    }
  }

  /// Fold result to handle both success and failure cases
  R fold<R>({
    required R Function(AppException error) onFailure,
    required R Function(T data) onSuccess,
  }) {
    if (_isSuccess && _data != null) {
      return onSuccess(_data!);
    } else {
      return onFailure(_error!);
    }
  }

  /// Get value or default if failure
  T getOrElse(T defaultValue) {
    return _isSuccess && _data != null ? _data! : defaultValue;
  }

  /// Get value or compute default if failure
  T getOrElseCompute(T Function() computeDefault) {
    return _isSuccess && _data != null ? _data! : computeDefault();
  }

  /// Filter success value with predicate
  Result<T> filter(bool Function(T data) predicate, {String? errorMessage}) {
    if (_isSuccess && _data != null) {
      if (predicate(_data!)) {
        return this;
      } else {
        return Result.failure(
          ValidationException(
            message: errorMessage ?? 'Filter condition not met',
          ),
        );
      }
    } else {
      return this;
    }
  }

  /// Validate success value with validator
  Result<T> validate({
    required bool Function(T data) validator,
    required String errorMessage,
  }) {
    return filter(validator, errorMessage: errorMessage);
  }

  /// Chain another operation that returns a Result
  Result<T> andThen(Result<T> Function() next) {
    if (_isSuccess) {
      try {
        return next();
      } catch (e, stackTrace) {
        return Result.failureFromException(e, stackTrace: stackTrace);
      }
    } else {
      return this;
    }
  }

  /// Chain another async operation that returns a Result
  Future<Result<T>> andThenAsync(Future<Result<T>> Function() next) async {
    if (_isSuccess) {
      try {
        return await next();
      } catch (e, stackTrace) {
        return Result.failureFromException(e, stackTrace: stackTrace);
      }
    } else {
      return this;
    }
  }

  /// Perform side effects on success
  Result<T> tap(void Function(T data) sideEffect) {
    if (_isSuccess && _data != null) {
      try {
        sideEffect(_data!);
      } catch (e) {
        // Ignore side effect errors
      }
    }
    return this;
  }

  /// Perform async side effects on success
  Future<Result<T>> tapAsync(Future<void> Function(T data) sideEffect) async {
    if (_isSuccess && _data != null) {
      try {
        await sideEffect(_data!);
      } catch (e) {
        // Ignore side effect errors
      }
    }
    return this;
  }

  /// Handle error and potentially recover
  Result<T> catchError(Result<T> Function(AppException error) recover) {
    if (_isFailure && _error != null) {
      try {
        return recover(_error!);
      } catch (e, stackTrace) {
        return Result.failureFromException(e, stackTrace: stackTrace);
      }
    } else {
      return this;
    }
  }

  /// Handle error with async recovery
  Future<Result<T>> catchErrorAsync(Future<Result<T>> Function(AppException error) recover) async {
    if (_isFailure && _error != null) {
      try {
        return await recover(_error!);
      } catch (e, stackTrace) {
        return Result.failureFromException(e, stackTrace: stackTrace);
      }
    } else {
      return this;
    }
  }

  /// Match on result type (more readable than fold)
  R match<R>({
    required R Function(T data) success,
    required R Function(AppException error) failure,
  }) {
    return fold(onSuccess: success, onFailure: failure);
  }

  /// Get user-friendly error information
  ErrorInfo? get errorInfo {
    if (_isFailure && _error != null) {
      return ErrorHandler.instance.handleError(_error!);
    }
    return null;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Result<T> &&
        other._isSuccess == _isSuccess &&
        other._data == _data &&
        other._error == _error;
  }

  @override
  int get hashCode => _isSuccess.hashCode ^ _data.hashCode ^ _error.hashCode;

  @override
  String toString() {
    if (_isSuccess) {
      return 'Result.success($_data)';
    } else {
      return 'Result.failure($_error)';
    }
  }
}

/// Extension methods for Result type
extension ResultExtensions<T> on Result<T> {
  /// Convert nullable Result to non-null type
  Result<T> whereNotNull() {
    return map((data) {
      if (data == null) {
        throw const ValidationException(message: 'Expected non-null value');
      }
      return data;
    });
  }

  /// Cast result to different type
  Result<R> cast<R>() {
    return map((data) => data as R);
  }

  /// Check if success value matches predicate
  bool contains(bool Function(T data) predicate) {
    return _isSuccess && _data != null && predicate(_data!);
  }

  /// Check if error matches specific type
  bool containsError<E extends AppException>() {
    return _isFailure && _error != null && _error is E;
  }

  /// Get error if it matches specific type
  E? getErrorOfType<E extends AppException>() {
    return _isFailure && _error != null && _error is E ? _error as E : null;
  }
}

/// Utility functions for creating Results
class Results {
  /// Create successful result
  static Result<T> success<T>(T data) => Result.success(data);

  /// Create failure result
  static Result<T> failure<T>(AppException error) => Result.failure(error);

  /// Create failure result from exception
  static Result<T> failureFromException<T>(dynamic exception, {String? message}) {
    return Result.failureFromException(exception, message: message);
  }

  /// Wrap async function in Result
  static Future<Result<T>> wrapAsync<T>(Future<T> Function() operation) async {
    try {
      final result = await operation();
      return Result.success(result);
    } catch (e, stackTrace) {
      return Result.failureFromException(e, stackTrace: stackTrace);
    }
  }

  /// Wrap synchronous function in Result
  static Result<T> wrap<T>(T Function() operation) {
    try {
      final result = operation();
      return Result.success(result);
    } catch (e, stackTrace) {
      return Result.failureFromException(e, stackTrace: stackTrace);
    }
  }

  /// Combine multiple results
  static Result<List<T>> combine<T>(List<Result<T>> results) {
    final dataList = <T>[];
    final errors = <AppException>[];

    for (final result in results) {
      if (result.isSuccess) {
        if (result._data != null) {
          dataList.add(result._data!);
        }
      } else {
        errors.add(result._error!);
      }
    }

    if (errors.isEmpty) {
      return Result.success(dataList);
    } else {
      // Return the first error
      return Result.failure(errors.first);
    }
  }
}