/// Result Type Tests
///
/// Unit tests for the enhanced Result type to ensure proper
/// functional error handling, chaining operations, and
/// type safety throughout the application.
///
/// Test Coverage:
/// - Success and failure creation
/// - Functional operations (map, flatMap, fold)
/// - Error handling and recovery
/// - Async operations
/// - Validation and filtering
///
/// Test Cases:
/// - ✅ Result.success() and Result.failure()
/// - ✅ Map and flatMap operations
/// - ✅ Fold pattern handling
/// - ✅ Error recovery mechanisms
/// - ✅ Validation and filtering
/// - ✅ Async chaining operations

import 'package:flutter_test/flutter_test.dart';

import '../../../../lib/core/types/result.dart';
import '../../../../lib/core/exceptions/app_exceptions.dart';

void main() {
  group('Result Type Tests', () {
    group('Result Creation', () {
      test('should create successful result with data', () {
        // Arrange
        const data = 'test data';

        // Act
        final result = Result.success(data);

        // Assert
        expect(result.isSuccess, true);
        expect(result.isFailure, false);
        expect(result.dataOrNull, data);
        expect(result.errorOrNull, null);
        expect(result.toString(), 'Result.success($data)');
      });

      test('should create failure result with error', () {
        // Arrange
        const error = ValidationException(errors: {'field': ['error']});

        // Act
        final result = Result.failure(error);

        // Assert
        expect(result.isSuccess, false);
        expect(result.isFailure, true);
        expect(result.dataOrNull, null);
        expect(result.errorOrNull, error);
        expect(result.toString(), 'Result.failure($error)');
      });

      test('should create failure result from exception', () {
        // Arrange
        final exception = Exception('test exception');

        // Act
        final result = Result.failureFromException(exception);

        // Assert
        expect(result.isFailure, true);
        expect(result.errorOrNull, isA<AppException>());
        expect(result.errorOrNull!.message, 'test exception');
        expect(result.errorOrNull!.originalError, exception);
      });

      test('should create failure result from exception with custom message', () {
        // Arrange
        final exception = Exception('test exception');
        const customMessage = 'Custom error message';

        // Act
        final result = Result.failureFromException(exception, message: customMessage);

        // Assert
        expect(result.isFailure, true);
        expect(result.errorOrNull!.message, customMessage);
      });
    });

    group('Data Access', () {
      test('should return data for successful result', () {
        // Arrange
        const data = 'test data';
        final result = Result.success(data);

        // Act
        final retrievedData = result.dataOrThrow;

        // Assert
        expect(retrievedData, data);
      });

      test('should throw for failure result when accessing dataOrThrow', () {
        // Arrange
        const error = NetworkException(message: 'Network error');
        final result = Result.failure(error);

        // Act & Assert
        expect(() => result.dataOrThrow, throwsA(isA<NetworkException>()));
      });

      test('should return null data for failure result', () {
        // Arrange
        const error = NetworkException(message: 'Network error');
        final result = Result.failure(error);

        // Act
        final data = result.dataOrNull;

        // Assert
        expect(data, null);
      });

      test('should return error message for failure result', () {
        // Arrange
        const error = NetworkException(message: 'Network error');
        final result = Result.failure(error);

        // Act
        final errorMessage = result.errorMessageOrNull;

        // Assert
        expect(errorMessage, 'Network error');
      });

      test('should return null error message for successful result', () {
        // Arrange
        const data = 'test data';
        final result = Result.success(data);

        // Act
        final errorMessage = result.errorMessageOrNull;

        // Assert
        expect(errorMessage, null);
      });
    });

    group('Map Operations', () {
      test('should map successful result', () {
        // Arrange
        const data = 'test';
        final result = Result.success(data);

        // Act
        final mappedResult = result.map((value) => '$value mapped');

        // Assert
        expect(mappedResult.isSuccess, true);
        expect(mappedResult.dataOrNull, 'test mapped');
      });

      test('should pass through failure result in map', () {
        // Arrange
        const error = NetworkException(message: 'Network error');
        final result = Result.failure(error);

        // Act
        final mappedResult = result.map((value) => '$value mapped');

        // Assert
        expect(mappedResult.isFailure, true);
        expect(mappedResult.errorOrNull, error);
      });

      test('should handle exception in map operation', () {
        // Arrange
        const data = 'test';
        final result = Result.success(data);

        // Act
        final mappedResult = result.map((value) => throw Exception('Map error'));

        // Assert
        expect(mappedResult.isFailure, true);
        expect(mappedResult.errorOrNull, isA<AppException>());
        expect(mappedResult.errorOrNull!.message, 'Map error');
      });

      test('should handle async map operation', () async {
        // Arrange
        const data = 'test';
        final result = Result.success(data);

        // Act
        final mappedResult = await result.mapAsync((value) async {
          await Future.delayed(const Duration(milliseconds: 10));
          return '$value mapped async';
        });

        // Assert
        expect(mappedResult.isSuccess, true);
        expect(mappedResult.dataOrNull, 'test mapped async');
      });

      test('should pass through failure result in async map', () async {
        // Arrange
        const error = NetworkException(message: 'Network error');
        final result = Result.failure(error);

        // Act
        final mappedResult = await result.mapAsync((value) => '$value mapped');

        // Assert
        expect(mappedResult.isFailure, true);
        expect(mappedResult.errorOrNull, error);
      });

      test('should handle exception in async map operation', () async {
        // Arrange
        const data = 'test';
        final result = Result.success(data);

        // Act
        final mappedResult = await result.mapAsync((value) async {
          await Future.delayed(const Duration(milliseconds: 10));
          throw Exception('Async map error');
        });

        // Assert
        expect(mappedResult.isFailure, true);
        expect(mappedResult.errorOrNull, isA<AppException>());
      });
    });

    group('FlatMap Operations', () {
      test('should flatMap successful result to new result', () {
        // Arrange
        const data = 5;
        final result = Result.success(data);

        // Act
        final flatMappedResult = result.flatMap((value) {
          if (value > 0) {
            return Result.success('positive');
          } else {
            return Result.failure(ValidationException(errors: {'value': ['must be positive']}));
          }
        });

        // Assert
        expect(flatMappedResult.isSuccess, true);
        expect(flatMappedResult.dataOrNull, 'positive');
      });

      test('should flatMap successful result to failure result', () {
        // Arrange
        const data = -1;
        final result = Result.success(data);

        // Act
        final flatMappedResult = result.flatMap((value) {
          if (value > 0) {
            return Result.success('positive');
          } else {
            return Result.failure(ValidationException(errors: {'value': ['must be positive']}));
          }
        });

        // Assert
        expect(flatMappedResult.isFailure, true);
        expect(flatMappedResult.errorOrNull, isA<ValidationException>());
      });

      test('should pass through failure result in flatMap', () {
        // Arrange
        const error = NetworkException(message: 'Network error');
        final result = Result.failure(error);

        // Act
        final flatMappedResult = result.flatMap((value) => Result.success('mapped'));

        // Assert
        expect(flatMappedResult.isFailure, true);
        expect(flatMappedResult.errorOrNull, error);
      });

      test('should handle exception in flatMap operation', () {
        // Arrange
        const data = 'test';
        final result = Result.success(data);

        // Act
        final flatMappedResult = result.flatMap((value) => throw Exception('FlatMap error'));

        // Assert
        expect(flatMappedResult.isFailure, true);
        expect(flatMappedResult.errorOrNull, isA<AppException>());
      });

      test('should handle async flatMap operation', () async {
        // Arrange
        const data = 5;
        final result = Result.success(data);

        // Act
        final flatMappedResult = await result.flatMapAsync((value) async {
          await Future.delayed(const Duration(milliseconds: 10));
          if (value > 0) {
            return Result.success('positive async');
          } else {
            return Result.failure(ValidationException(errors: {'value': ['must be positive']}));
          }
        });

        // Assert
        expect(flatMappedResult.isSuccess, true);
        expect(flatMappedResult.dataOrNull, 'positive async');
      });

      test('should pass through failure result in async flatMap', () async {
        // Arrange
        const error = NetworkException(message: 'Network error');
        final result = Result.failure(error);

        // Act
        final flatMappedResult = await result.flatMapAsync((value) => Result.success('mapped'));

        // Assert
        expect(flatMappedResult.isFailure, true);
        expect(flatMappedResult.errorOrNull, error);
      });

      test('should handle exception in async flatMap operation', () async {
        // Arrange
        const data = 'test';
        final result = Result.success(data);

        // Act
        final flatMappedResult = await result.flatMapAsync((value) async {
          await Future.delayed(const Duration(milliseconds: 10));
          throw Exception('Async flatMap error');
        });

        // Assert
        expect(flatMappedResult.isFailure, true);
        expect(flatMappedResult.errorOrNull, isA<AppException>());
      });
    });

    group('Fold Operations', () {
      test('should execute onSuccess callback for successful result', () {
        // Arrange
        const data = 'test data';
        final result = Result.success(data);
        var onSuccessCalled = false;
        var onFailureCalled = false;

        // Act
        final foldedResult = result.fold(
          onFailure: (error) {
            onFailureCalled = true;
            return 'error: $error';
          },
          onSuccess: (value) {
            onSuccessCalled = true;
            return 'success: $value';
          },
        );

        // Assert
        expect(onSuccessCalled, true);
        expect(onFailureCalled, false);
        expect(foldedResult, 'success: test data');
      });

      test('should execute onFailure callback for failure result', () {
        // Arrange
        const error = NetworkException(message: 'Network error');
        final result = Result.failure(error);
        var onSuccessCalled = false;
        var onFailureCalled = false;

        // Act
        final foldedResult = result.fold(
          onFailure: (error) {
            onFailureCalled = true;
            return 'error: $error';
          },
          onSuccess: (value) {
            onSuccessCalled = true;
            return 'success: $value';
          },
        );

        // Assert
        expect(onSuccessCalled, false);
        expect(onFailureCalled, true);
        expect(foldedResult, 'error: NetworkException: Network error');
      });

      test('should handle complex fold operation', () {
        // Arrange
        final result = Result.success(42);

        // Act
        final foldedResult = result.fold(
          onFailure: (error) => -1,
          onSuccess: (value) => value * 2,
        );

        // Assert
        expect(foldedResult, 84);
      });
    });

    group('GetOrElse Operations', () {
      test('should return data for successful result', () {
        // Arrange
        const data = 'test';
        final result = Result.success(data);
        const defaultValue = 'default';

        // Act
        final retrievedData = result.getOrElse(defaultValue);

        // Assert
        expect(retrievedData, data);
      });

      test('should return default value for failure result', () {
        // Arrange
        const error = NetworkException(message: 'Network error');
        final result = Result.failure(error);
        const defaultValue = 'default';

        // Act
        final retrievedData = result.getOrElse(defaultValue);

        // Assert
        expect(retrievedData, defaultValue);
      });

      test('should return computed default value for failure result', () {
        // Arrange
        const error = NetworkException(message: 'Network error');
        final result = Result.failure(error);

        // Act
        final retrievedData = result.getOrElseCompute(() => 'computed default');

        // Assert
        expect(retrievedData, 'computed default');
      });

      test('should not call compute function for successful result', () {
        // Arrange
        const data = 'test';
        final result = Result.success(data);
        var computeCalled = false;

        // Act
        final retrievedData = result.getOrElseCompute(() {
          computeCalled = true;
          return 'computed';
        });

        // Assert
        expect(retrievedData, data);
        expect(computeCalled, false);
      });
    });

    group('Filter and Validation Operations', () {
      test('should filter successful result that passes predicate', () {
        // Arrange
        const data = 10;
        final result = Result.success(data);

        // Act
        final filteredResult = result.filter((value) => value > 5);

        // Assert
        expect(filteredResult.isSuccess, true);
        expect(filteredResult.dataOrNull, data);
      });

      test('should create failure result for successful result that fails predicate', () {
        // Arrange
        const data = 10;
        final result = Result.success(data);

        // Act
        final filteredResult = result.filter((value) => value > 15);

        // Assert
        expect(filteredResult.isFailure, true);
        expect(filteredResult.errorOrNull, isA<ValidationException>());
        expect(filteredResult.errorOrNull!.message, 'Filter condition not met');
      });

      test('should pass through failure result in filter', () {
        // Arrange
        const error = NetworkException(message: 'Network error');
        final result = Result.failure(error);

        // Act
        final filteredResult = result.filter((value) => true);

        // Assert
        expect(filteredResult.isFailure, true);
        expect(filteredResult.errorOrNull, error);
      });

      test('should validate successful result that passes validator', () {
        // Arrange
        const data = 'test@example.com';
        final result = Result.success(data);

        // Act
        final validatedResult = result.validate(
          validator: (value) => value.contains('@'),
          errorMessage: 'Invalid email format',
        );

        // Assert
        expect(validatedResult.isSuccess, true);
        expect(validatedResult.dataOrNull, data);
      });

      test('should create failure result for successful result that fails validation', () {
        // Arrange
        const data = 'invalid-email';
        final result = Result.success(data);

        // Act
        final validatedResult = result.validate(
          validator: (value) => value.contains('@'),
          errorMessage: 'Invalid email format',
        );

        // Assert
        expect(validatedResult.isFailure, true);
        expect(validatedResult.errorOrNull, isA<ValidationException>());
        expect(validatedResult.errorOrNull!.message, 'Invalid email format');
      });

      test('should pass through failure result in validate', () {
        // Arrange
        const error = NetworkException(message: 'Network error');
        final result = Result.failure(error);

        // Act
        final validatedResult = result.validate(
          validator: (value) => true,
          errorMessage: 'Should not be called',
        );

        // Assert
        expect(validatedResult.isFailure, true);
        expect(validatedResult.errorOrNull, error);
      });
    });

    group('Chaining Operations', () {
      test('should chain successful operations with andThen', () {
        // Arrange
        final result = Result.success(5);

        // Act
        final chainedResult = result
            .andThen(() => Result.success(10))
            .andThen(() => Result.success(15));

        // Assert
        expect(chainedResult.isSuccess, true);
        expect(chainedResult.dataOrNull, 15);
      });

      test('should stop chaining on first failure with andThen', () {
        // Arrange
        const error = NetworkException(message: 'Network error');
        final result = Result.success(5);

        // Act
        final chainedResult = result
            .andThen(() => Result.failure(error))
            .andThen(() => Result.success(10)); // This should not be called

        // Assert
        expect(chainedResult.isFailure, true);
        expect(chainedResult.errorOrNull, error);
      });

      test('should handle exception in andThen operation', () {
        // Arrange
        final result = Result.success(5);

        // Act
        final chainedResult = result.andThen(() => throw Exception('AndThen error'));

        // Assert
        expect(chainedResult.isFailure, true);
        expect(chainedResult.errorOrNull, isA<AppException>());
      });

      test('should chain async operations with andThenAsync', () async {
        // Arrange
        final result = Result.success(5);

        // Act
        final chainedResult = await result
            .andThenAsync(() async {
              await Future.delayed(const Duration(milliseconds: 10));
              return Result.success(10);
            })
            .andThenAsync(() async {
              await Future.delayed(const Duration(milliseconds: 10));
              return Result.success(15);
            });

        // Assert
        expect(chainedResult.isSuccess, true);
        expect(chainedResult.dataOrNull, 15);
      });

      test('should stop async chaining on first failure', () async {
        // Arrange
        const error = NetworkException(message: 'Network error');
        final result = Result.success(5);

        // Act
        final chainedResult = await result
            .andThenAsync(() async {
              await Future.delayed(const Duration(milliseconds: 10));
              return Result.failure(error);
            })
            .andThenAsync(() async {
              await Future.delayed(const Duration(milliseconds: 10));
              return Result.success(10); // This should not be called
            });

        // Assert
        expect(chainedResult.isFailure, true);
        expect(chainedResult.errorOrNull, error);
      });
    });

    group('Side Effect Operations', () {
      test('should execute side effect for successful result with tap', () {
        // Arrange
        const data = 'test';
        final result = Result.success(data);
        var sideEffectCalled = false;

        // Act
        final tappedResult = result.tap((value) {
          sideEffectCalled = true;
        });

        // Assert
        expect(tappedResult, result); // Should return same result
        expect(sideEffectCalled, true);
        expect(tappedResult.dataOrNull, data);
      });

      test('should not execute side effect for failure result with tap', () {
        // Arrange
        const error = NetworkException(message: 'Network error');
        final result = Result.failure(error);
        var sideEffectCalled = false;

        // Act
        final tappedResult = result.tap((value) {
          sideEffectCalled = true;
        });

        // Assert
        expect(tappedResult, result); // Should return same result
        expect(sideEffectCalled, false);
        expect(tappedResult.errorOrNull, error);
      });

      test('should ignore side effect exceptions in tap', () {
        // Arrange
        const data = 'test';
        final result = Result.success(data);

        // Act
        final tappedResult = result.tap((value) => throw Exception('Side effect error'));

        // Assert
        expect(tappedResult, result); // Should return same result despite exception
        expect(tappedResult.dataOrNull, data);
      });

      test('should execute async side effect for successful result with tapAsync', () async {
        // Arrange
        const data = 'test';
        final result = Result.success(data);
        var sideEffectCalled = false;

        // Act
        final tappedResult = await result.tapAsync((value) async {
          await Future.delayed(const Duration(milliseconds: 10));
          sideEffectCalled = true;
        });

        // Assert
        expect(tappedResult, result); // Should return same result
        expect(sideEffectCalled, true);
        expect(tappedResult.dataOrNull, data);
      });

      test('should ignore async side effect exceptions in tapAsync', () async {
        // Arrange
        const data = 'test';
        final result = Result.success(data);

        // Act
        final tappedResult = await result.tapAsync((value) async {
          await Future.delayed(const Duration(milliseconds: 10));
          throw Exception('Async side effect error');
        });

        // Assert
        expect(tappedResult, result); // Should return same result despite exception
        expect(tappedResult.dataOrNull, data);
      });
    });

    group('Error Recovery Operations', () {
      test('should recover from error with catchError', () {
        // Arrange
        const error = NetworkException(message: 'Network error');
        final result = Result.failure(error);

        // Act
        final recoveredResult = result.catchError((error) {
          if (error is NetworkException) {
            return Result.success('recovered');
          }
          return Result.failure(error);
        });

        // Assert
        expect(recoveredResult.isSuccess, true);
        expect(recoveredResult.dataOrNull, 'recovered');
      });

      test('should not recover if error type not handled', () {
        // Arrange
        const error = ValidationException(errors: {'field': ['error']});
        final result = Result.failure(error);

        // Act
        final recoveredResult = result.catchError((error) {
          if (error is NetworkException) {
            return Result.success('recovered');
          }
          return Result.failure(error);
        });

        // Assert
        expect(recoveredResult.isFailure, true);
        expect(recoveredResult.errorOrNull, error);
      });

      test('should handle exception in catchError operation', () {
        // Arrange
        const error = NetworkException(message: 'Network error');
        final result = Result.failure(error);

        // Act
        final recoveredResult = result.catchError((error) => throw Exception('CatchError error'));

        // Assert
        expect(recoveredResult.isFailure, true);
        expect(recoveredResult.errorOrNull, isA<AppException>());
      });

      test('should recover from error with async catchError', () async {
        // Arrange
        const error = NetworkException(message: 'Network error');
        final result = Result.failure(error);

        // Act
        final recoveredResult = await result.catchErrorAsync((error) async {
          await Future.delayed(const Duration(milliseconds: 10));
          if (error is NetworkException) {
            return Result.success('recovered async');
          }
          return Result.failure(error);
        });

        // Assert
        expect(recoveredResult.isSuccess, true);
        expect(recoveredResult.dataOrNull, 'recovered async');
      });

      test('should not recover async if error type not handled', () async {
        // Arrange
        const error = ValidationException(errors: {'field': ['error']});
        final result = Result.failure(error);

        // Act
        final recoveredResult = await result.catchErrorAsync((error) async {
          await Future.delayed(const Duration(milliseconds: 10));
          if (error is NetworkException) {
            return Result.success('recovered');
          }
          return Result.failure(error);
        });

        // Assert
        expect(recoveredResult.isFailure, true);
        expect(recoveredResult.errorOrNull, error);
      });
    });

    group('Match Operations', () {
      test('should execute success callback in match for successful result', () {
        // Arrange
        const data = 'test';
        final result = Result.success(data);
        var successCalled = false;
        var failureCalled = false;

        // Act
        final matchedResult = result.match(
          success: (value) {
            successCalled = true;
            return 'success: $value';
          },
          failure: (error) {
            failureCalled = true;
            return 'failure: $error';
          },
        );

        // Assert
        expect(successCalled, true);
        expect(failureCalled, false);
        expect(matchedResult, 'success: test');
      });

      test('should execute failure callback in match for failure result', () {
        // Arrange
        const error = NetworkException(message: 'Network error');
        final result = Result.failure(error);
        var successCalled = false;
        var failureCalled = false;

        // Act
        final matchedResult = result.match(
          success: (value) {
            successCalled = true;
            return 'success: $value';
          },
          failure: (error) {
            failureCalled = true;
            return 'failure: $error';
          },
        );

        // Assert
        expect(successCalled, false);
        expect(failureCalled, true);
        expect(matchedResult, 'failure: NetworkException: Network error');
      });
    });

    group('Extension Methods', () {
      group('contains method', () {
        test('should return true when predicate matches', () {
          // Arrange
          const data = 10;
          final result = Result.success(data);

          // Act
          final contains = result.contains((value) => value > 5);

          // Assert
          expect(contains, true);
        });

        test('should return false when predicate does not match', () {
          // Arrange
          const data = 10;
          final result = Result.success(data);

          // Act
          final contains = result.contains((value) => value > 15);

          // Assert
          expect(contains, false);
        });

        test('should return false for failure result', () {
          // Arrange
          const error = NetworkException(message: 'Network error');
          final result = Result.failure(error);

          // Act
          final contains = result.contains((value) => true);

          // Assert
          expect(contains, false);
        });
      });

      group('containsError method', () {
        test('should return true when error matches type', () {
          // Arrange
          const error = NetworkException(message: 'Network error');
          final result = Result.failure(error);

          // Act
          final containsError = result.containsError<NetworkException>();

          // Assert
          expect(containsError, true);
        });

        test('should return false when error does not match type', () {
          // Arrange
          const error = NetworkException(message: 'Network error');
          final result = Result.failure(error);

          // Act
          final containsError = result.containsError<ValidationException>();

          // Assert
          expect(containsError, false);
        });

        test('should return false for successful result', () {
          // Arrange
          const data = 'test';
          final result = Result.success(data);

          // Act
          final containsError = result.containsError<NetworkException>();

          // Assert
          expect(containsError, false);
        });
      });

      group('getErrorOfType method', () {
        test('should return error when type matches', () {
          // Arrange
          const error = NetworkException(message: 'Network error');
          final result = Result.failure(error);

          // Act
          final typedError = result.getErrorOfType<NetworkException>();

          // Assert
          expect(typedError, error);
        });

        test('should return null when type does not match', () {
          // Arrange
          const error = NetworkException(message: 'Network error');
          final result = Result.failure(error);

          // Act
          final typedError = result.getErrorOfType<ValidationException>();

          // Assert
          expect(typedError, null);
        });

        test('should return null for successful result', () {
          // Arrange
          const data = 'test';
          final result = Result.success(data);

          // Act
          final typedError = result.getErrorOfType<NetworkException>();

          // Assert
          expect(typedError, null);
        });
      });
    });

    group('Equality and HashCode', () {
      test('should be equal when results have same success state and data', () {
        // Arrange
        const data = 'test';
        final result1 = Result.success(data);
        final result2 = Result.success(data);

        // Act & Assert
        expect(result1, result2);
        expect(result1.hashCode, result2.hashCode);
      });

      test('should be equal when results have same failure state and error', () {
        // Arrange
        const error = NetworkException(message: 'Network error');
        final result1 = Result.failure(error);
        final result2 = Result.failure(error);

        // Act & Assert
        expect(result1, result2);
        expect(result1.hashCode, result2.hashCode);
      });

      test('should not be equal when results have different states', () {
        // Arrange
        final successResult = Result.success('success');
        final failureResult = Result.failure(const NetworkException(message: 'error'));

        // Act & Assert
        expect(successResult, isNot(failureResult));
        expect(successResult.hashCode, isNot(failureResult.hashCode));
      });

      test('should not be equal when results have different data', () {
        // Arrange
        final result1 = Result.success('data1');
        final result2 = Result.success('data2');

        // Act & Assert
        expect(result1, isNot(result2));
        expect(result1.hashCode, isNot(result2.hashCode));
      });
    });

    group('Results Utility Class', () {
      test('should create successful result', () {
        // Arrange
        const data = 'test data';

        // Act
        final result = Results.success(data);

        // Assert
        expect(result.isSuccess, true);
        expect(result.dataOrNull, data);
      });

      test('should create failure result', () {
        // Arrange
        const error = NetworkException(message: 'Network error');

        // Act
        final result = Results.failure(error);

        // Assert
        expect(result.isFailure, true);
        expect(result.errorOrNull, error);
      });

      test('should create failure result from exception', () {
        // Arrange
        final exception = Exception('test exception');

        // Act
        final result = Results.failureFromException(exception);

        // Assert
        expect(result.isFailure, true);
        expect(result.errorOrNull, isA<AppException>());
        expect(result.errorOrNull!.originalError, exception);
      });

      test('should wrap successful synchronous operation', () {
        // Arrange
        String operation() => 'success';

        // Act
        final result = Results.wrap(operation);

        // Assert
        expect(result.isSuccess, true);
        expect(result.dataOrNull, 'success');
      });

      test('should wrap failed synchronous operation', () {
        // Arrange
        String operation() => throw Exception('operation error');

        // Act
        final result = Results.wrap(operation);

        // Assert
        expect(result.isFailure, true);
        expect(result.errorOrNull, isA<AppException>());
      });

      test('should wrap successful async operation', () async {
        // Arrange
        Future<String> operation() async {
          await Future.delayed(const Duration(milliseconds: 10));
          return 'async success';
        }

        // Act
        final result = await Results.wrapAsync(operation);

        // Assert
        expect(result.isSuccess, true);
        expect(result.dataOrNull, 'async success');
      });

      test('should wrap failed async operation', () async {
        // Arrange
        Future<String> operation() async {
          await Future.delayed(const Duration(milliseconds: 10));
          throw Exception('async operation error');
        }

        // Act
        final result = await Results.wrapAsync(operation);

        // Assert
        expect(result.isFailure, true);
        expect(result.errorOrNull, isA<AppException>());
      });

      test('should combine multiple successful results', () {
        // Arrange
        final results = [
          Results.success('item1'),
          Results.success('item2'),
          Results.success('item3'),
        ];

        // Act
        final combinedResult = Results.combine(results);

        // Assert
        expect(combinedResult.isSuccess, true);
        expect(combinedResult.dataOrNull, ['item1', 'item2', 'item3']);
      });

      test('should combine results with first error', () {
        // Arrange
        final results = [
          Results.success('item1'),
          Results.failure(const NetworkException(message: 'error1')),
          Results.failure(const NetworkException(message: 'error2')),
        ];

        // Act
        final combinedResult = Results.combine(results);

        // Assert
        expect(combinedResult.isFailure, true);
        expect(combinedResult.errorOrNull, const NetworkException(message: 'error1'));
      });

      test('should combine empty list of results', () {
        // Arrange
        final results = <Result<String>>[];

        // Act
        final combinedResult = Results.combine(results);

        // Assert
        expect(combinedResult.isSuccess, true);
        expect(combinedResult.dataOrNull, []);
      });
    });
  });
}