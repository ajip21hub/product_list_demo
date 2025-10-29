/// Test Helpers
///
/// Utility functions and mock classes for testing purposes.
/// This file provides common testing utilities to reduce
/// boilerplate code and ensure consistent test setup.
///
/// Features:
/// - Mock data generators
/// - Test utilities
/// - Common fixtures
/// - Testing setup helpers
///
/// Example usage:
/// ```dart
/// final mockProduct = MockProductGenerator.createProduct();
/// final container = createTestContainer();
/// ```

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import '../../lib/core/dependency_injection.dart';
import '../../lib/data/models/product.dart';
import '../../lib/data/models/user.dart';
import '../../lib/data/repositories/product_repository.dart';
import '../../lib/data/repositories/user_repository.dart';
import '../../lib/data/repositories/session_repository.dart';
import '../../lib/data/datasources/api_service.dart';
import '../../lib/data/datasources/auth_service.dart';
import '../../lib/core/exceptions/app_exceptions.dart';
import '../../lib/core/services/error_handler.dart';

// Generate mocks
@GenerateMocks([
  ProductRepository,
  UserRepository,
  SessionRepository,
  ApiService,
  AuthService,
])
import 'test_helpers.mocks.dart';

/// Test container for dependency injection
class TestContainer {
  final ProviderContainer container;
  final Map<Type, dynamic> mocks;

  TestContainer({required this.container, required this.mocks});

  T getMock<T>() => mocks[T] as T;

  void read<T>(ProviderListenable<T> provider) => container.read(provider);
  ProviderListenable<T> watch<T>(ProviderListenable<T> provider) => container.listen(provider, null);
}

/// Create test container with mocked dependencies
TestContainer createTestContainer() {
  final mocks = <Type, dynamic>{
    ProductRepository: MockProductRepository(),
    UserRepository: MockUserRepository(),
    SessionRepository: MockSessionRepository(),
    ApiService: MockApiService(),
    AuthService: MockAuthService(),
  };

  // Override providers with mocks
  final container = ProviderContainer(
    overrides: [
      productRepositoryProvider.overrideWithValue(mocks[ProductRepository]!),
      userRepositoryProvider.overrideWithValue(mocks[UserRepository]!),
      sessionRepositoryProvider.overrideWithValue(mocks[SessionRepository]!),
      apiServiceProvider.overrideWithValue(mocks[ApiService]!),
      authServiceProvider.overrideWithValue(mocks[AuthService]!),
    ],
  );

  return TestContainer(container: container, mocks: mocks);
}

/// Mock data generators
class MockProductGenerator {
  static Product createProduct({
    int id = 1,
    String title = 'Test Product',
    double price = 99.99,
    String description = 'Test Description',
    String category = 'electronics',
    String image = 'https://example.com/image.jpg',
    Rating rating = const Rating(rate: 4.5, count: 100),
  }) {
    return Product(
      id: id,
      title: title,
      price: price,
      description: description,
      category: category,
      image: image,
      rating: rating,
    );
  }

  static List<Product> createProductList({int count = 5}) {
    return List.generate(count, (index) => createProduct(
      id: index + 1,
      title: 'Product ${index + 1}',
      price: 99.99 + (index * 10),
      category: ['electronics', 'clothing', 'books'][index % 3],
    ));
  }

  static Product createFeaturedProduct() {
    return createProduct(
      id: 100,
      title: 'Featured Product',
      price: 199.99,
      rating: const Rating(rate: 4.8, count: 250),
      category: 'electronics',
    );
  }

  static Product createProductOnSale() {
    return createProduct(
      id: 200,
      title: 'Sale Product',
      price: 149.99,
      rating: const Rating(rate: 4.2, count: 180),
      category: 'clothing',
    );
  }
}

/// Mock user data generator
class MockUserGenerator {
  static User createUser({
    int id = 1,
    String username = 'testuser',
    String email = 'test@example.com',
    String fullName = 'Test User',
    String avatar = 'https://example.com/avatar.jpg',
  }) {
    return User(
      id: id,
      username: username,
      email: email,
      fullName: fullName,
      avatar: avatar,
    );
  }

  static User createAdminUser() {
    return createUser(
      id: 999,
      username: 'admin',
      email: 'admin@example.com',
      fullName: 'Administrator',
      avatar: 'https://example.com/admin.jpg',
    );
  }
}

/// Mock exception generators
class MockExceptionGenerator {
  static NetworkException createNetworkException({
    String message = 'Network error',
    int? statusCode,
  }) {
    return NetworkException(
      message: message,
      statusCode: statusCode,
      url: 'https://example.com/api',
    );
  }

  static ServerException createServerException({
    String message = 'Server error',
    int statusCode = 500,
  }) {
    return ServerException(
      message: message,
      statusCode: statusCode,
      url: 'https://example.com/api',
    );
  }

  static AuthenticationException createAuthException({
    String message = 'Authentication failed',
  }) {
    return AuthenticationException(message: message);
  }

  static ValidationException createValidationException({
    Map<String, List<String>> errors = const {},
  }) {
    return ValidationException(
      errors: errors.isEmpty
        ? {'field': ['This field is required']}
        : errors,
    );
  }

  static NotFoundException createNotFoundException({
    String message = 'Resource not found',
    String? resourceType,
    String? resourceId,
  }) {
    return NotFoundException(
      message: message,
      resourceType: resourceType,
      resourceId: resourceId,
    );
  }
}

/// Common test utilities
class TestUtils {
  /// Verify that a Result is successful and contains expected data
  static void expectResultSuccess<T>(Result<T> result, T? expectedData) {
    expect(result.isSuccess, true, reason: 'Result should be successful');
    if (expectedData != null) {
      expect(result.dataOrThrow, expectedData);
    }
  }

  /// Verify that a Result is a failure with expected error type
  static void expectResultFailure<T>(Result<T> result, Type expectedErrorType) {
    expect(result.isFailure, true, reason: 'Result should be a failure');
    expect(result.errorOrNull, isA<expectedErrorType>());
  }

  /// Create a Future that completes with delay
  static Future<T> delayedFuture<T>(T value, [Duration? delay]) {
    return Future.delayed(delay ?? const Duration(milliseconds: 100), () => value);
  }

  /// Create a Future that fails with exception
  static Future<T> failedFuture<T>(Exception exception) {
    return Future.delayed(const Duration(milliseconds: 50), () => throw exception);
  }

  /// Wait for async operations to complete
  static Future<void> pumpAndSettle(WidgetTester tester, {Duration? duration}) async {
    await tester.pump(duration ?? const Duration(milliseconds: 100));
    await tester.pumpAndSettle();
  }

  /// Verify that a widget exists and has expected properties
  static void expectWidgetExists<T extends Widget>(
    WidgetTester tester, {
    Type? widgetType,
    String? text,
    Icon? icon,
    Key? key,
  }) {
    if (widgetType != null) {
      expect(find.byType(widgetType), findsOneWidget);
    }
    if (text != null) {
      expect(find.text(text), findsOneWidget);
    }
    if (icon != null) {
      expect(find.byIcon(icon.icon), findsOneWidget);
    }
    if (key != null) {
      expect(find.byKey(key), findsOneWidget);
    }
  }

  /// Setup common test environment
  static void setupTestEnvironment() {
    // Reset dependency injection
    DependencyInjection.reset();

    // Setup test dependencies
    DependencyInjection.setup();

    // Reset error handler
    ErrorHandler.reset();
  }

  /// Cleanup test environment
  static void cleanupTestEnvironment() {
    DependencyInjection.reset();
    ErrorHandler.reset();
  }
}

/// Custom matchers for testing
extension CustomMatchers on Matcher {
  static Matcher isSuccessfulResult() => predicate((Result result) => result.isSuccess);
  static Matcher isFailureResult() => predicate((Result result) => result.isFailure);
  static Matcher isProductWithId(int id) => predicate((Product product) => product.id == id);
  static Matcher isUserWithUsername(String username) => predicate((User user) => user.username == username);
}

/// Test data fixtures
class TestDataFixtures {
  static const List<String> sampleCategories = [
    'All',
    'electronics',
    'clothing',
    'books',
    'home',
    'sports',
  ];

  static const List<String> sampleSearchQueries = [
    'laptop',
    'phone',
    'book',
    'shirt',
    'shoes',
  ];

  static const Map<String, dynamic> sampleUserData = {
    'username': 'newuser',
    'email': 'newuser@example.com',
    'fullName': 'New User',
    'avatar': 'https://example.com/newavatar.jpg',
  };

  static const Map<String, dynamic> sampleUserPreferences = {
    'theme': 'dark',
    'notifications': true,
    'language': 'en',
    'currency': 'USD',
  };
}

/// Performance testing utilities
class PerformanceTestUtils {
  static Future<void> measureExecutionTime(
    String operationName,
    Future<void> Function() operation,
  ) async {
    final stopwatch = Stopwatch()..start();
    await operation();
    stopwatch.stop();

    print('$operationName took ${stopwatch.elapsedMilliseconds}ms');

    // Assert reasonable performance limits
    expect(stopwatch.elapsedMilliseconds, lessThan(5000),
           reason: '$operationName should complete within 5 seconds');
  }

  static Future<void> measureMemoryUsage(
    String operationName,
    Future<void> Function() operation,
  ) async {
    // Memory measurement would require platform-specific implementation
    // This is a placeholder for memory testing
    await operation();
  }
}

/// Integration test utilities
class IntegrationTestUtils {
  static Future<void> setupIntegrationTest() async {
    // Setup integration test environment
    TestUtils.setupTestEnvironment();

    // Additional setup for integration tests
    // - Database setup
    // - Network mocking
    // - File system setup
  }

  static Future<void> cleanupIntegrationTest() async {
    // Cleanup integration test environment
    TestUtils.cleanupTestEnvironment();

    // Additional cleanup for integration tests
    // - Database cleanup
    // - Network cleanup
    // - File system cleanup
  }
}