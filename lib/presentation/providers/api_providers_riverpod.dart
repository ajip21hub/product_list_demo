/// API Providers using Riverpod
///
/// Riverpod providers for API data fetching with proper error handling
/// and caching strategies for products and categories.
///
/// Example usage:
/// ```dart
/// final productsAsync = ref.watch(productsProvider);
/// final categoriesAsync = ref.watch(categoriesProvider);
/// ```

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../models/product.dart';

// Provider for ApiService
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

// FutureProvider for products
final productsProvider = FutureProvider<List<Product>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  return await apiService.getProducts();
});

// FutureProvider for categories
final categoriesProvider = FutureProvider<List<String>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  return await apiService.getCategories();
});

// Provider for products by category
final productsByCategoryProvider = FutureProvider.family<List<Product>, String>((ref, category) async {
  final apiService = ref.watch(apiServiceProvider);
  if (category == 'All') {
    return await apiService.getProducts();
  }
  return await apiService.getProductsByCategory(category);
});

// Provider for single product by ID
final productByIdProvider = FutureProvider.family<Product?, int>((ref, productId) async {
  final apiService = ref.watch(apiServiceProvider);
  return await apiService.getProductById(productId);
});

// Provider for searching products
final searchProductsProvider = FutureProvider.family<List<Product>, String>((ref, query) async {
  final apiService = ref.watch(apiServiceProvider);
  return await apiService.searchProducts(query);
});

// AsyncNotifier for products with refresh capability
class ProductsNotifier extends AsyncNotifier<List<Product>> {
  late final ApiService _apiService;

  @override
  Future<List<Product>> build() async {
    _apiService = ref.watch(apiServiceProvider);
    return await _loadProducts();
  }

  Future<List<Product>> _loadProducts() async {
    try {
      return await _apiService.getProducts();
    } catch (e, stack) {
      throw Exception('Failed to load products: $e');
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      state = AsyncValue.data(await _loadProducts());
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

// Provider for refreshable products
final refreshableProductsProvider = AsyncNotifierProvider<ProductsNotifier, List<Product>>(() {
  return ProductsNotifier();
});

// Provider for categories with refresh capability
class CategoriesNotifier extends AsyncNotifier<List<String>> {
  late final ApiService _apiService;

  @override
  Future<List<String>> build() async {
    _apiService = ref.watch(apiServiceProvider);
    return await _loadCategories();
  }

  Future<List<String>> _loadCategories() async {
    try {
      return await _apiService.getCategories();
    } catch (e, stack) {
      throw Exception('Failed to load categories: $e');
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      state = AsyncValue.data(await _loadCategories());
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

// Provider for refreshable categories
final refreshableCategoriesProvider = AsyncNotifierProvider<CategoriesNotifier, List<String>>(() {
  return CategoriesNotifier();
});