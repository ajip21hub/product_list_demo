import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Product List Provider using Riverpod
///
/// A modern, compile-safe state management solution for product list functionality.
/// This provider handles product fetching, category filtering, and loading states
/// using Riverpod's state management.
///
/// Example usage:
/// ```dart
/// final productListState = ref.watch(productListProvider);
/// final productListNotifier = ref.read(productListProvider.notifier);
///
/// // Load products
/// await productListNotifier.loadProducts();
///
/// // Filter by category
/// await productListNotifier.filterByCategory('electronics');
///
/// // Refresh data
/// await productListNotifier.refresh();
/// ```
import '../../data/models/product.dart';
import '../../data/datasources/api_service.dart';
import '../../core/dependency_injection.dart';

// State class for product list
class ProductListState {
  final List<Product> products;
  final List<String> categories;
  final String selectedCategory;
  final bool isLoading;
  final String? error;

  const ProductListState({
    this.products = const [],
    this.categories = const [],
    this.selectedCategory = 'All',
    this.isLoading = false,
    this.error,
  });

  ProductListState copyWith({
    List<Product>? products,
    List<String>? categories,
    String? selectedCategory,
    bool? isLoading,
    String? error,
  }) {
    return ProductListState(
      products: products ?? this.products,
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  // Getters
  bool get isEmpty => products.isEmpty;
  bool get isNotEmpty => products.isNotEmpty;
  bool get hasError => error != null;

  List<Product> get filteredProducts {
    if (selectedCategory == 'All') return products;
    return products.where((product) => product.category == selectedCategory).toList();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductListState &&
        other.products.length == products.length &&
        other.categories.length == categories.length &&
        other.selectedCategory == selectedCategory &&
        other.isLoading == isLoading &&
        other.error == error;
  }

  @override
  int get hashCode =>
      products.hashCode ^
      categories.hashCode ^
      selectedCategory.hashCode ^
      isLoading.hashCode ^
      error.hashCode;

  @override
  String toString() =>
      'ProductListState(productCount: ${products.length}, categoryCount: ${categories.length}, '
      'selectedCategory: $selectedCategory, isLoading: $isLoading, hasError: $hasError)';
}

// Notifier class for product list state management
class ProductListNotifier extends StateNotifier<ProductListState> {
  ProductListNotifier(this._apiService) : super(const ProductListState());

  final ApiService _apiService;

  // Load all products and categories
  Future<void> loadProducts() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final products = await _apiService.getProducts();
      final categories = await _apiService.getCategories();

      state = state.copyWith(
        products: products,
        categories: categories,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  // Filter products by category
  Future<void> filterByCategory(String category) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final products = category == 'All'
          ? await _apiService.getProducts()
          : await _apiService.getProductsByCategory(category);

      state = state.copyWith(
        products: products,
        selectedCategory: category,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  // Refresh data (reload current category)
  Future<void> refresh() async {
    if (state.selectedCategory == 'All') {
      await loadProducts();
    } else {
      await filterByCategory(state.selectedCategory);
    }
  }

  // Reset to initial state
  void reset() {
    state = const ProductListState();
  }

  // Set loading state manually
  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider definition
final productListProvider = StateNotifierProvider<ProductListNotifier, ProductListState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return ProductListNotifier(apiService);
});

// Convenience providers for commonly used values
final productsProvider = Provider<List<Product>>((ref) {
  return ref.watch(productListProvider).products;
});

final categoriesProvider = Provider<List<String>>((ref) {
  return ref.watch(productListProvider).categories;
});

final selectedCategoryProvider = Provider<String>((ref) {
  return ref.watch(productListProvider).selectedCategory;
});

final filteredProductsProvider = Provider<List<Product>>((ref) {
  return ref.watch(productListProvider).filteredProducts;
});

final productListIsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(productListProvider).isLoading;
});

final productListErrorProvider = Provider<String?>((ref) {
  return ref.watch(productListProvider).error;
});

final productListIsEmptyProvider = Provider<bool>((ref) {
  return ref.watch(productListProvider).isEmpty;
});

final productListIsNotEmptyProvider = Provider<bool>((ref) {
  return ref.watch(productListProvider).isNotEmpty;
});

final productListHasErrorProvider = Provider<bool>((ref) {
  return ref.watch(productListProvider).hasError;
});