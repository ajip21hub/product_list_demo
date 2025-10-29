/// Dependency Injection Container
///
/// Central dependency injection setup following SOLID principles.
/// This container manages all repository and service dependencies,
/// making it easy to test and swap implementations.
///
/// Features:
/// - Centralized dependency management
/// - Easy testing with mock implementations
/// - Singleton pattern for shared services
/// - Type-safe dependency resolution
///
/// Example usage:
/// ```dart
/// // Setup dependencies
/// DependencyInjection.setup();
///
/// // Get dependencies
/// final productRepository = DependencyInjection.get<ProductRepository>();
/// final authRepository = DependencyInjection.get<AuthRepository>();
/// ```

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/datasources/api_service.dart';
import '../data/datasources/auth_service.dart';
import '../data/repositories/product_repository.dart';
import '../data/repositories/product_repository_impl.dart';
import '../data/repositories/user_repository.dart';
import '../data/repositories/user_repository_impl.dart';
import '../data/repositories/session_repository.dart';
import '../data/repositories/session_repository_impl.dart';

// Core dependency injection container
class DependencyInjection {
  static final Map<Type, dynamic> _instances = {};

  /// Register a dependency
  static void register<T>(T instance) {
    _instances[T] = instance;
  }

  /// Get a dependency
  static T get<T>() {
    final instance = _instances[T];
    if (instance == null) {
      throw Exception('Dependency of type $T not registered');
    }
    return instance as T;
  }

  /// Check if a dependency is registered
  static bool isRegistered<T>() {
    return _instances.containsKey(T);
  }

  /// Clear all dependencies (useful for testing)
  static void clear() {
    _instances.clear();
  }

  /// Setup all dependencies
  static void setup() {
    // Register services
    register<ApiService>(ApiService());
    register<AuthService>(AuthService());

    // Register repositories
    final productRepository = ProductRepositoryImpl(get<ApiService>());
    register<ProductRepository>(productRepository);

    final userRepository = UserRepositoryImpl(get<AuthService>());
    register<UserRepository>(userRepository);

    final sessionRepository = SessionRepositoryImpl(get<AuthService>());
    register<SessionRepository>(sessionRepository);
  }

  /// Setup test dependencies (with mock implementations)
  static void setupTest() {
    // Override with test implementations when needed
    setup();
  }
}

// Riverpod providers using dependency injection

// Service providers
final apiServiceProvider = Provider<ApiService>((ref) {
  return DependencyInjection.get<ApiService>();
});

final authServiceProvider = Provider<AuthService>((ref) {
  return DependencyInjection.get<AuthService>();
});

// Repository providers
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return DependencyInjection.get<ProductRepository>();
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return DependencyInjection.get<UserRepository>();
});

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  return DependencyInjection.get<SessionRepository>();
});

// Factory provider for creating repository implementations
final productRepositoryFactoryProvider = Provider<ProductRepositoryImpl>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return ProductRepositoryImpl(apiService);
});

final userRepositoryFactoryProvider = Provider<UserRepositoryImpl>((ref) {
  final authService = ref.watch(authServiceProvider);
  return UserRepositoryImpl(authService);
});

final sessionRepositoryFactoryProvider = Provider<SessionRepositoryImpl>((ref) {
  final authService = ref.watch(authServiceProvider);
  return SessionRepositoryImpl(authService);
});

// Dependency injection initializer
class DependencyInjectionInitializer {
  static bool _isInitialized = false;

  static void initialize() {
    if (!_isInitialized) {
      DependencyInjection.setup();
      _isInitialized = true;
    }
  }

  static void initializeForTesting() {
    if (!_isInitialized) {
      DependencyInjection.setupTest();
      _isInitialized = true;
    }
  }

  static bool get isInitialized => _isInitialized;

  static void reset() {
    DependencyInjection.clear();
    _isInitialized = false;
  }
}

// Provider for dependency injection status
final isDependencyInjectionInitializedProvider = Provider<bool>((ref) {
  return DependencyInjectionInitializer.isInitialized;
});

// Provider to force dependency initialization
final dependencyInitializerProvider = FutureProvider<void>((ref) async {
  if (!DependencyInjectionInitializer.isInitialized) {
    DependencyInjectionInitializer.initialize();
  }
});