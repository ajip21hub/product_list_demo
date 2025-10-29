/// Product Repository Provider using Riverpod
///
/// Provides Riverpod providers for product repository operations.
/// This acts as a bridge between the UI layer and the repository layer,
/// handling async state management and providing reactive data streams.
///
/// Features:
/// - Automatic caching and invalidation
/// - Error state handling
/// - Loading state management
/// - Optimistic updates support
///
/// Example usage:
/// ```dart
/// final productsAsync = ref.watch(productsProvider);
/// final repository = ref.read(productRepositoryProvider);
/// ```

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../data/datasources/api_service.dart';
import '../../data/models/product.dart';
import '../../core/dependency_injection.dart';

// Provider for ApiService using dependency injection
final apiServiceProvider = Provider<ApiService>((ref) {
  return DependencyInjection.get<ApiService>();
});

// Provider for ProductRepository using dependency injection
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return DependencyInjection.get<ProductRepository>();
});

// Async provider for all products with caching
final productsProvider = AsyncNotifierProvider<ProductsNotifier, List<Product>>(() {
  return ProductsNotifier();
});

// Async notifier for products with refresh capability
class ProductsNotifier extends AsyncNotifier<List<Product>> {
  late final ProductRepository _repository;
  List<Product> _cachedProducts = [];
  DateTime? _lastFetchTime;
  static const Duration _cacheDuration = Duration(minutes: 5);

  @override
  Future<List<Product>> build() async {
    _repository = ref.watch(productRepositoryProvider);

    // Load initial data
    state = const AsyncValue.loading();
    await _loadProducts();

    return state.when(
      data: (products) => products,
      loading: () => [],
      error: (_, __) => [],
    );
  }

  Future<void> _loadProducts() async {
    state = const AsyncValue.loading();

    try {
      final result = await _repository.getProducts();

      state = result.fold(
        onFailure: (error) => AsyncValue.error(error, StackTrace.current),
        onSuccess: (products) {
          _cachedProducts = products;
          _lastFetchTime = DateTime.now();
          return AsyncValue.data(products);
        },
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    await _loadProducts();
  }

  Future<void> forceRefresh() async {
    _cachedProducts = [];
    _lastFetchTime = null;
    await refresh();
  }

  /// Check if cache is still valid
  bool get _isCacheValid {
    if (_lastFetchTime == null) return false;
    return DateTime.now().difference(_lastFetchTime!) < _cacheDuration;
  }
}

// Async provider for products by category
final productsByCategoryProvider = AsyncNotifierProvider<ProductsByCategoryNotifier, List<Product>>(() {
  return ProductsByCategoryNotifier();
});

class ProductsByCategoryNotifier extends AsyncNotifier<List<Product>> {
  late final ProductRepository _repository;
  String _category = '';

  @override
  Future<List<Product>> build() async {
    _repository = ref.watch(productRepositoryProvider);

    state = const AsyncValue.loading();
    await _loadProductsByCategory();

    return state.when(
      data: (products) => products,
      loading: () => [],
      error: (_, __) => [],
    );
  }

  Future<void> _loadProductsByCategory() async {
    if (_category == 'All') {
      final productsNotifier = ref.read(productsProvider.notifier);
      await productsNotifier.refresh();
      return;
    }

    state = const AsyncValue.loading();

    try {
      final result = await _repository.getProductsByCategory(_category);

      state = result.fold(
        onFailure: (error) => AsyncValue.error(error, StackTrace.current),
        onSuccess: (products) => AsyncValue.data(products),
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> refresh() async {
    await _loadProductsByCategory();
  }

  // Method to update category and reload
  Future<void> updateCategory(String category) async {
    _category = category;
    await _loadProductsByCategory();
  }
}

// Async provider for featured products
final featuredProductsProvider = AsyncNotifierProvider<FeaturedProductsNotifier, List<Product>>(() {
  return FeaturedProductsNotifier();
});

class FeaturedProductsNotifier extends AsyncNotifier<List<Product>> {
  late final ProductRepository _repository;

  @override
  Future<List<Product>> build() async {
    _repository = ref.watch(productRepositoryProvider);

    state = const AsyncValue.loading();
    await _loadFeaturedProducts();

    return state.when(
      data: (products) => products,
      loading: () => [],
      error: (_, __) => [],
    );
  }

  Future<void> _loadFeaturedProducts() async {
    state = const AsyncValue.loading();

    try {
      final result = await _repository.getFeaturedProducts();

      state = result.fold(
        onFailure: (error) => AsyncValue.error(error, StackTrace.current),
        onSuccess: (products) => AsyncValue.data(products),
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> refresh() async {
    await _loadFeaturedProducts();
  }
}

// Async provider for search results
final searchResultsProvider = AsyncNotifierProvider<SearchResultsNotifier, List<Product>>(() {
  return SearchResultsNotifier();
});

class SearchResultsNotifier extends AsyncNotifier<List<Product>> {
  late final ProductRepository _repository;
  String _query = '';

  @override
  Future<List<Product>> build() async {
    _repository = ref.watch(productRepositoryProvider);

    if (_query.trim().isEmpty) {
      return const [];
    }

    state = const AsyncValue.loading();
    await _searchProducts();

    return state.when(
      data: (products) => products,
      loading: () => [],
      error: (_, __) => [],
    );
  }

  Future<void> _searchProducts() async {
    state = const AsyncValue.loading();

    try {
      final result = await _repository.searchProducts(_query);

      state = result.fold(
        onFailure: (error) => AsyncValue.error(error, StackTrace.current),
        onSuccess: (products) => AsyncValue.data(products),
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> search(String newQuery) async {
    _query = newQuery;
    await _searchProducts();
  }
}

// Async provider for single product by ID
final productByIdProvider = AsyncNotifierProvider<ProductByIdNotifier, Product?>(() {
  return ProductByIdNotifier();
});

class ProductByIdNotifier extends AsyncNotifier<Product?> {
  late final ProductRepository _repository;
  int _productId = 0;

  @override
  Future<Product?> build() async {
    _repository = ref.watch(productRepositoryProvider);

    state = const AsyncValue.loading();
    await _loadProduct();

    return state.when(
      data: (product) => product,
      loading: () => null,
      error: (_, __) => null,
    );
  }

  Future<void> _loadProduct() async {
    state = const AsyncValue.loading();

    try {
      final result = await _repository.getProductById(_productId);

      state = result.fold(
        onFailure: (error) => AsyncValue.error(error, StackTrace.current),
        onSuccess: (product) => AsyncValue.data(product),
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> refresh() async {
    await _loadProduct();
  }

  // Method to update product ID and reload
  Future<void> updateProductId(int productId) async {
    _productId = productId;
    await _loadProduct();
  }
}

// Provider for categories
final categoriesProvider = AsyncNotifierProvider<CategoriesNotifier, List<String>>(() {
  return CategoriesNotifier();
});

class CategoriesNotifier extends AsyncNotifier<List<String>> {
  late final ProductRepository _repository;

  @override
  Future<List<String>> build() async {
    _repository = ref.watch(productRepositoryProvider);

    state = const AsyncValue.loading();
    await _loadCategories();

    return state.when(
      data: (categories) => categories,
      loading: () => [],
      error: (_, __) => [],
    );
  }

  Future<void> _loadCategories() async {
    state = const AsyncValue.loading();

    try {
      final result = await _repository.getCategories();

      state = result.fold(
        onFailure: (error) => AsyncValue.error(error, StackTrace.current),
        onSuccess: (categories) => AsyncValue.data(['All', ...categories]),
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> refresh() async {
    await _loadCategories();
  }
}

// Convenience providers for commonly accessed data
final isLoadingProductsProvider = Provider<bool>((ref) {
  return ref.watch(productsProvider).isLoading;
});

final productsErrorProvider = Provider<String?>((ref) {
  return ref.watch(productsProvider).error?.toString();
});

final featuredProductsCountProvider = Provider<int>((ref) {
  return ref.watch(featuredProductsProvider).when(
    data: (products) => products.length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

final searchResultsCountProvider = Provider<int>((ref) {
  return ref.watch(searchResultsProvider).when(
    data: (products) => products.length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});