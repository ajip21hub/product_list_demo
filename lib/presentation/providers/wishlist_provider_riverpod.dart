/// Wishlist Provider using Riverpod
///
/// A modern, compile-safe state management solution for wishlist functionality.
/// This provider handles wishlist operations including adding items, removing items,
/// and checking if products are favorited using Riverpod's state management.
///
/// Example usage:
/// ```dart
/// final wishlistState = ref.watch(wishlistProvider);
/// final wishlistNotifier = ref.read(wishlistProvider.notifier);
///
/// // Toggle favorite status
/// wishlistNotifier.toggleFavorite(product);
///
/// // Remove from wishlist
/// wishlistNotifier.removeFavorite(product);
///
/// // Check if product is favorited
/// final isFavorited = ref.watch(isProductFavoritedProvider(product));
/// ```

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/product.dart';

// State class for wishlist
class WishlistState {
  final List<Product> items;
  final bool isLoading;

  const WishlistState({
    this.items = const [],
    this.isLoading = false,
  });

  WishlistState copyWith({
    List<Product>? items,
    bool? isLoading,
  }) {
    return WishlistState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  // Getters
  int get itemCount => items.length;
  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;

  bool isFavorite(Product product) {
    return items.any((item) => item.id == product.id);
  }

  Product? getProduct(int productId) {
    try {
      return items.firstWhere((item) => item.id == productId);
    } catch (e) {
      return null;
    }
  }

  List<Product> getProductsByCategory(String category) {
    return items.where((product) => product.category == category).toList();
  }

  int getCountByCategory(String category) {
    return items.where((product) => product.category == category).length;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WishlistState &&
        other.items.length == items.length &&
        other.itemCount == itemCount &&
        other.isLoading == isLoading;
  }

  @override
  int get hashCode => items.hashCode ^ itemCount.hashCode ^ isLoading.hashCode;

  @override
  String toString() => 'WishlistState(itemCount: $itemCount, isLoading: $isLoading)';
}

// Notifier class for wishlist state management
class WishlistNotifier extends StateNotifier<WishlistState> {
  WishlistNotifier() : super(const WishlistState());

  // Toggle favorite status of a product
  void toggleFavorite(Product product) {
    if (state.isFavorite(product)) {
      removeFavorite(product);
    } else {
      addToFavorites(product);
    }
  }

  // Add product to favorites
  void addToFavorites(Product product) {
    if (!state.isFavorite(product)) {
      final updatedItems = List<Product>.from(state.items)..add(product);
      state = state.copyWith(items: updatedItems);
    }
  }

  // Remove product from favorites
  void removeFavorite(Product product) {
    final updatedItems = state.items.where((item) => item.id != product.id).toList();
    state = state.copyWith(items: updatedItems);
  }

  // Remove product by ID
  void removeFavoriteById(int productId) {
    final updatedItems = state.items.where((item) => item.id != productId).toList();
    state = state.copyWith(items: updatedItems);
  }

  // Clear all favorites
  void clearFavorites() {
    state = const WishlistState();
  }

  // Add multiple products to favorites
  void addMultipleToFavorites(List<Product> products) {
    final newItems = products.where((product) => !state.isFavorite(product));
    final updatedItems = List<Product>.from(state.items)..addAll(newItems);
    state = state.copyWith(items: updatedItems);
  }

  // Remove multiple products from favorites
  void removeMultipleFromFavorites(List<int> productIds) {
    final updatedItems = state.items.where((item) => !productIds.contains(item.id)).toList();
    state = state.copyWith(items: updatedItems);
  }

  // Set loading state
  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  // Check if all products in a list are favorited
  bool areAllFavorited(List<Product> products) {
    return products.every((product) => state.isFavorite(product));
  }

  // Get count of favorited products by category
  int getCountByCategory(String category) {
    return state.items.where((product) => product.category == category).length;
  }

  // Get wishlist summary
  Map<String, dynamic> getWishlistSummary() {
    return {
      'itemCount': state.itemCount,
      'isEmpty': state.isEmpty,
      'isNotEmpty': state.isNotEmpty,
      'items': state.items,
      'categories': state.items.map((p) => p.category).toSet().toList(),
    };
  }
}

// Provider definition
final wishlistProvider = StateNotifierProvider<WishlistNotifier, WishlistState>((ref) {
  return WishlistNotifier();
});

// Convenience providers for commonly used values
final wishlistItemCountProvider = Provider<int>((ref) {
  return ref.watch(wishlistProvider).itemCount;
});

final wishlistItemsProvider = Provider<List<Product>>((ref) {
  return ref.watch(wishlistProvider).items;
});

final wishlistIsEmptyProvider = Provider<bool>((ref) {
  return ref.watch(wishlistProvider).isEmpty;
});

final wishlistIsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(wishlistProvider).isLoading;
});

// Provider to check if specific product is favorited
final isProductFavoritedProvider = Provider.family<bool, Product>((ref, product) {
  return ref.watch(wishlistProvider).isFavorite(product);
});

// Provider to check if product is favorited by ID
final isProductFavoritedByIdProvider = Provider.family<bool, int>((ref, productId) {
  return ref.watch(wishlistProvider).items.any((item) => item.id == productId);
});

// Provider to get favorited products by category
final wishlistProductsByCategoryProvider = Provider.family<List<Product>, String>((ref, category) {
  return ref.watch(wishlistProvider).getProductsByCategory(category);
});

// Provider to get count of favorited products by category
final wishlistCountByCategoryProvider = Provider.family<int, String>((ref, category) {
  return ref.watch(wishlistProvider).getCountByCategory(category);
});