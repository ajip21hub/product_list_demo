/// Product Repository Provider Tests
///
/// Unit tests for the product repository provider to ensure
/// proper state management, error handling, and data flow.
///
/// Test Coverage:
/// - Product loading states
/// - Error handling scenarios
/// - Caching mechanisms
/// - Search functionality
/// - Category filtering
///
/// Test Cases:
/// - ✅ Load products successfully
/// - ✅ Handle network errors
/// - ✅ Handle server errors
/// - ✅ Search products
/// - ✅ Filter by category
/// - ✅ Refresh functionality
/// - ✅ Caching behavior

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import '../../../lib/data/models/product.dart';
import '../../../lib/core/exceptions/app_exceptions.dart';
import '../../../lib/core/types/result.dart';
import '../../../lib/presentation/providers/product_repository_provider.dart';
import '../test_helpers/test_helpers.dart';

@GenerateMocks([ProductsNotifier, ProductsByCategoryNotifier, FeaturedProductsNotifier])
import 'product_repository_provider_test.mocks.dart';

void main() {
  group('ProductRepositoryProvider Tests', () {
    late ProviderContainer container;
    late MockProductRepository mockRepository;

    setUp(() {
      mockRepository = MockProductRepository();
      TestUtils.setupTestEnvironment();

      container = ProviderContainer(
        overrides: [
          productRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
      TestUtils.cleanupTestEnvironment();
    });

    group('ProductsNotifier', () {
      test('should load products successfully', () async {
        // Arrange
        final mockProducts = MockProductGenerator.createProductList();
        when(mockRepository.getProducts())
            .thenAnswer((_) async => Result.success(mockProducts));

        final notifier = ProductsNotifier();
        notifier._repository = mockRepository;

        // Act
        await notifier._loadProducts();

        // Assert
        expect(notifier.state.isLoading, false);
        expect(notifier.state.hasValue, true);
        expect(notifier.state.value, mockProducts);
        verify(mockRepository.getProducts()).called(1);
      });

      test('should handle network errors', () async {
        // Arrange
        final networkError = MockExceptionGenerator.createNetworkException();
        when(mockRepository.getProducts())
            .thenAnswer((_) async => Result.failure(networkError));

        final notifier = ProductsNotifier();
        notifier._repository = mockRepository;

        // Act
        await notifier._loadProducts();

        // Assert
        expect(notifier.state.isLoading, false);
        expect(notifier.state.hasError, true);
        expect(notifier.state.error, isA<NetworkException>());
        verify(mockRepository.getProducts()).called(1);
      });

      test('should handle server errors', () async {
        // Arrange
        final serverError = MockExceptionGenerator.createServerException();
        when(mockRepository.getProducts())
            .thenAnswer((_) async => Result.failure(serverError));

        final notifier = ProductsNotifier();
        notifier._repository = mockRepository;

        // Act
        await notifier._loadProducts();

        // Assert
        expect(notifier.state.isLoading, false);
        expect(notifier.state.hasError, true);
        expect(notifier.state.error, isA<ServerException>());
        verify(mockRepository.getProducts()).called(1);
      });

      test('should refresh products', () async {
        // Arrange
        final mockProducts = MockProductGenerator.createProductList();
        when(mockRepository.getProducts())
            .thenAnswer((_) async => Result.success(mockProducts));

        final notifier = ProductsNotifier();
        notifier._repository = mockRepository;

        // Act
        await notifier.refresh();

        // Assert
        verify(mockRepository.getProducts()).called(1);
        expect(notifier.state.value, mockProducts);
      });

      test('should force refresh products', () async {
        // Arrange
        final mockProducts = MockProductGenerator.createProductList();
        when(mockRepository.getProducts())
            .thenAnswer((_) async => Result.success(mockProducts));

        final notifier = ProductsNotifier();
        notifier._repository = mockRepository;
        notifier._cachedProducts = MockProductGenerator.createProductList(count: 3);
        notifier._lastFetchTime = DateTime.now().subtract(const Duration(minutes: 10));

        // Act
        await notifier.forceRefresh();

        // Assert
        expect(notifier._cachedProducts, []);
        expect(notifier._lastFetchTime, null);
        verify(mockRepository.getProducts()).called(1);
      });

      test('should use cache when valid', () async {
        // Arrange
        final cachedProducts = MockProductGenerator.createProductList(count: 3);
        final notifier = ProductsNotifier();
        notifier._repository = mockRepository;
        notifier._cachedProducts = cachedProducts;
        notifier._lastFetchTime = DateTime.now().subtract(const Duration(minutes: 2));

        // Act
        final isValid = notifier._isCacheValid;

        // Assert
        expect(isValid, true);
        verifyNever(mockRepository.getProducts());
      });

      test('should not use cache when invalid', () async {
        // Arrange
        final notifier = ProductsNotifier();
        notifier._repository = mockRepository;
        notifier._cachedProducts = MockProductGenerator.createProductList(count: 3);
        notifier._lastFetchTime = DateTime.now().subtract(const Duration(minutes: 10));

        // Act
        final isValid = notifier._isCacheValid;

        // Assert
        expect(isValid, false);
      });
    });

    group('ProductsByCategoryNotifier', () {
      test('should load products by category successfully', () async {
        // Arrange
        final electronicsProducts = MockProductGenerator.createProductList(count: 3)
            .map((p) => p.copyWith(category: 'electronics'))
            .toList();

        when(mockRepository.getProductsByCategory('electronics'))
            .thenAnswer((_) async => Result.success(electronicsProducts));

        final notifier = ProductsByCategoryNotifier();
        notifier._repository = mockRepository;
        notifier._category = 'electronics';

        // Act
        await notifier._loadProductsByCategory();

        // Assert
        expect(notifier.state.isLoading, false);
        expect(notifier.state.hasValue, true);
        expect(notifier.state.value, electronicsProducts);
        verify(mockRepository.getProductsByCategory('electronics')).called(1);
      });

      test('should handle "All" category by loading all products', () async {
        // Arrange
        final mockProducts = MockProductGenerator.createProductList();
        when(mockRepository.getProducts())
            .thenAnswer((_) async => Result.success(mockProducts));

        final notifier = ProductsByCategoryNotifier();
        notifier._repository = mockRepository;
        notifier._category = 'All';

        // Act
        await notifier._loadProductsByCategory();

        // Assert
        verify(mockRepository.getProducts()).called(1);
        verifyNever(mockRepository.getProductsByCategory(any));
      });

      test('should handle category loading errors', () async {
        // Arrange
        final error = MockExceptionGenerator.createNotFoundException(
          message: 'Category not found',
          resourceType: 'category',
        );

        when(mockRepository.getProductsByCategory('invalid'))
            .thenAnswer((_) async => Result.failure(error));

        final notifier = ProductsByCategoryNotifier();
        notifier._repository = mockRepository;
        notifier._category = 'invalid';

        // Act
        await notifier._loadProductsByCategory();

        // Assert
        expect(notifier.state.isLoading, false);
        expect(notifier.state.hasError, true);
        expect(notifier.state.error, isA<NotFoundException>());
        verify(mockRepository.getProductsByCategory('invalid')).called(1);
      });

      test('should update category and reload', () async {
        // Arrange
        final clothingProducts = MockProductGenerator.createProductList(count: 2)
            .map((p) => p.copyWith(category: 'clothing'))
            .toList();

        when(mockRepository.getProductsByCategory('clothing'))
            .thenAnswer((_) async => Result.success(clothingProducts));

        final notifier = ProductsByCategoryNotifier();
        notifier._repository = mockRepository;
        notifier._category = 'electronics';

        // Act
        await notifier.updateCategory('clothing');

        // Assert
        expect(notifier._category, 'clothing');
        verify(mockRepository.getProductsByCategory('clothing')).called(1);
      });
    });

    group('FeaturedProductsNotifier', () {
      test('should load featured products successfully', () async {
        // Arrange
        final featuredProducts = [
          MockProductGenerator.createFeaturedProduct(),
          MockProductGenerator.createProduct(id: 101, rating: const Rating(rate: 4.7, count: 150)),
        ];

        when(mockRepository.getFeaturedProducts())
            .thenAnswer((_) async => Result.success(featuredProducts));

        final notifier = FeaturedProductsNotifier();
        notifier._repository = mockRepository;

        // Act
        await notifier._loadFeaturedProducts();

        // Assert
        expect(notifier.state.isLoading, false);
        expect(notifier.state.hasValue, true);
        expect(notifier.state.value, featuredProducts);
        verify(mockRepository.getFeaturedProducts()).called(1);
      });

      test('should handle featured products loading errors', () async {
        // Arrange
        final error = MockExceptionGenerator.createNetworkException();
        when(mockRepository.getFeaturedProducts())
            .thenAnswer((_) async => Result.failure(error));

        final notifier = FeaturedProductsNotifier();
        notifier._repository = mockRepository;

        // Act
        await notifier._loadFeaturedProducts();

        // Assert
        expect(notifier.state.isLoading, false);
        expect(notifier.state.hasError, true);
        expect(notifier.state.error, isA<NetworkException>());
        verify(mockRepository.getFeaturedProducts()).called(1);
      });
    });

    group('SearchResultsNotifier', () {
      test('should search products successfully', () async {
        // Arrange
        final searchResults = MockProductGenerator.createProductList(count: 3)
            .where((p) => p.title.contains('laptop'))
            .toList();

        when(mockRepository.searchProducts('laptop'))
            .thenAnswer((_) async => Result.success(searchResults));

        final notifier = SearchResultsNotifier();
        notifier._repository = mockRepository;
        notifier._query = 'laptop';

        // Act
        await notifier._searchProducts();

        // Assert
        expect(notifier.state.isLoading, false);
        expect(notifier.state.hasValue, true);
        expect(notifier.state.value, searchResults);
        verify(mockRepository.searchProducts('laptop')).called(1);
      });

      test('should handle empty search query', () async {
        // Arrange
        final notifier = SearchResultsNotifier();
        notifier._repository = mockRepository;
        notifier._query = '';

        // Act
        await notifier._searchProducts();

        // Assert
        expect(notifier.state.hasValue, true);
        expect(notifier.state.value, []);
        verifyNever(mockRepository.searchProducts(any));
      });

      test('should handle search errors', () async {
        // Arrange
        final error = MockExceptionGenerator.createServerException();
        when(mockRepository.searchProducts('invalid'))
            .thenAnswer((_) async => Result.failure(error));

        final notifier = SearchResultsNotifier();
        notifier._repository = mockRepository;
        notifier._query = 'invalid';

        // Act
        await notifier._searchProducts();

        // Assert
        expect(notifier.state.isLoading, false);
        expect(notifier.state.hasError, true);
        expect(notifier.state.error, isA<ServerException>());
        verify(mockRepository.searchProducts('invalid')).called(1);
      });

      test('should update search query', () async {
        // Arrange
        final newResults = MockProductGenerator.createProductList(count: 2)
            .where((p) => p.title.contains('phone'))
            .toList();

        when(mockRepository.searchProducts('phone'))
            .thenAnswer((_) async => Result.success(newResults));

        final notifier = SearchResultsNotifier();
        notifier._repository = mockRepository;
        notifier._query = 'laptop';

        // Act
        await notifier.search('phone');

        // Assert
        expect(notifier._query, 'phone');
        verify(mockRepository.searchProducts('phone')).called(1);
      });
    });

    group('CategoriesNotifier', () {
      test('should load categories successfully', () async {
        // Arrange
        const categories = ['electronics', 'clothing', 'books'];
        when(mockRepository.getCategories())
            .thenAnswer((_) async => Result.success(categories));

        final notifier = CategoriesNotifier();
        notifier._repository = mockRepository;

        // Act
        await notifier._loadCategories();

        // Assert
        expect(notifier.state.isLoading, false);
        expect(notifier.state.hasValue, true);
        expect(notifier.state.value, ['All', ...categories]);
        verify(mockRepository.getCategories()).called(1);
      });

      test('should handle categories loading errors', () async {
        // Arrange
        final error = MockExceptionGenerator.createNetworkException();
        when(mockRepository.getCategories())
            .thenAnswer((_) async => Result.failure(error));

        final notifier = CategoriesNotifier();
        notifier._repository = mockRepository;

        // Act
        await notifier._loadCategories();

        // Assert
        expect(notifier.state.isLoading, false);
        expect(notifier.state.hasError, true);
        expect(notifier.state.error, isA<NetworkException>());
        verify(mockRepository.getCategories()).called(1);
      });
    });

    group('Provider Integration Tests', () {
      test('productsProvider should load and provide products', () async {
        // Arrange
        final mockProducts = MockProductGenerator.createProductList();
        when(mockRepository.getProducts())
            .thenAnswer((_) async => Result.success(mockProducts));

        // Act
        final productsListenable = container.read(productsProvider);
        await container.read(productsProvider.notifier)._loadProducts();

        // Assert
        expect(productsListenable.isLoading, false);
        expect(productsListenable.hasValue, true);
        expect(productsListenable.value, mockProducts);
      });

      test('featuredProductsProvider should load and provide featured products', () async {
        // Arrange
        final featuredProducts = [MockProductGenerator.createFeaturedProduct()];
        when(mockRepository.getFeaturedProducts())
            .thenAnswer((_) async => Result.success(featuredProducts));

        // Act
        final featuredListenable = container.read(featuredProductsProvider);
        await container.read(featuredProductsProvider.notifier)._loadFeaturedProducts();

        // Assert
        expect(featuredListenable.isLoading, false);
        expect(featuredListenable.hasValue, true);
        expect(featuredListenable.value, featuredProducts);
      });

      test('categoriesProvider should load and provide categories', () async {
        // Arrange
        const categories = ['electronics', 'clothing'];
        when(mockRepository.getCategories())
            .thenAnswer((_) async => Result.success(categories));

        // Act
        final categoriesListenable = container.read(categoriesProvider);
        await container.read(categoriesProvider.notifier)._loadCategories();

        // Assert
        expect(categoriesListenable.isLoading, false);
        expect(categoriesListenable.hasValue, true);
        expect(categoriesListenable.value, ['All', ...categories]);
      });
    });

    group('Convenience Providers', () {
      test('isLoadingProductsProvider should reflect loading state', () {
        // Arrange
        final testContainer = createTestContainer();
        final notifier = ProductsNotifier();
        notifier.state = const AsyncValue.loading();

        // Act & Assert
        expect(testContainer.read(isLoadingProductsProvider), true);
      });

      test('productsErrorProvider should reflect error state', () {
        // Arrange
        final testContainer = createTestContainer();
        final error = MockExceptionGenerator.createNetworkException();
        final notifier = ProductsNotifier();
        notifier.state = AsyncValue.error(error, StackTrace.current);

        // Act & Assert
        expect(testContainer.read(productsErrorProvider), error.toString());
      });

      test('featuredProductsCountProvider should return count', () {
        // Arrange
        final testContainer = createTestContainer();
        final notifier = FeaturedProductsNotifier();
        final products = MockProductGenerator.createProductList(count: 3);
        notifier.state = AsyncValue.data(products);

        // Act & Assert
        expect(testContainer.read(featuredProductsCountProvider), 3);
      });
    });
  });
}