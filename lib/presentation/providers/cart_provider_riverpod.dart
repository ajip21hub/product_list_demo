/// Cart Provider using Riverpod
///
/// A modern, compile-safe state management solution for shopping cart functionality.
/// This provider handles cart operations including adding items, removing items,
/// updating quantities, and calculating totals using Riverpod's state management.
///
/// Example usage:
/// ```dart
/// final cartState = ref.watch(cartProvider);
/// final cartNotifier = ref.read(cartProvider.notifier);
///
/// // Add item to cart
/// cartNotifier.addItem(product);
///
/// // Remove item from cart
/// cartNotifier.removeItem(product);
///
/// // Update quantity
/// cartNotifier.updateQuantity(product, 3);
/// ```

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/product.dart';
import '../../data/models/cart_item.dart';

// State class for shopping cart
class CartState {
  final List<CartItem> items;
  final bool isLoading;

  const CartState({
    this.items = const [],
    this.isLoading = false,
  });

  CartState copyWith({
    List<CartItem>? items,
    bool? isLoading,
  }) {
    return CartState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  // Getters
  int get itemCount => items.fold(0, (total, item) => total + item.quantity);
  double get totalAmount => items.fold(0, (total, item) => total + item.totalPrice);
  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;

  bool isInCart(Product product) {
    return items.any((item) => item.product.id == product.id);
  }

  CartItem? getItem(Product product) {
    try {
      return items.firstWhere((item) => item.product.id == product.id);
    } catch (e) {
      return null;
    }
  }

  int getQuantity(Product product) {
    final item = getItem(product);
    return item?.quantity ?? 0;
  }

  double getItemTotal(Product product) {
    final item = getItem(product);
    return item?.totalPrice ?? 0.0;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartState &&
        other.items.length == items.length &&
        other.itemCount == itemCount &&
        other.totalAmount == totalAmount &&
        other.isLoading == isLoading;
  }

  @override
  int get hashCode => items.hashCode ^ itemCount.hashCode ^ totalAmount.hashCode ^ isLoading.hashCode;

  @override
  String toString() => 'CartState(itemCount: $itemCount, totalAmount: $totalAmount, isLoading: $isLoading)';
}

// Notifier class for cart state management
class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(const CartState());

  // Add item to cart
  void addItem(Product product, {int quantity = 1}) {
    final existingItemIndex = state.items.indexWhere((item) => item.product.id == product.id);

    if (existingItemIndex >= 0) {
      // Update existing item quantity
      final updatedItems = List<CartItem>.from(state.items);
      updatedItems[existingItemIndex] = CartItem(
        product: product,
        quantity: updatedItems[existingItemIndex].quantity + quantity,
      );
      state = state.copyWith(items: updatedItems);
    } else {
      // Add new item
      final updatedItems = List<CartItem>.from(state.items)
        ..add(CartItem(product: product, quantity: quantity));
      state = state.copyWith(items: updatedItems);
    }
  }

  // Remove item from cart
  void removeItem(Product product) {
    final updatedItems = state.items.where((item) => item.product.id != product.id).toList();
    state = state.copyWith(items: updatedItems);
  }

  // Remove single quantity of item
  void removeSingleItem(Product product) {
    final existingItemIndex = state.items.indexWhere((item) => item.product.id == product.id);

    if (existingItemIndex >= 0) {
      final updatedItems = List<CartItem>.from(state.items);
      final currentQuantity = updatedItems[existingItemIndex].quantity;

      if (currentQuantity > 1) {
        // Decrease quantity
        updatedItems[existingItemIndex] = CartItem(
          product: product,
          quantity: currentQuantity - 1,
        );
      } else {
        // Remove item completely
        updatedItems.removeAt(existingItemIndex);
      }

      state = state.copyWith(items: updatedItems);
    }
  }

  // Update item quantity
  void updateQuantity(Product product, int quantity) {
    if (quantity <= 0) {
      removeItem(product);
      return;
    }

    final existingItemIndex = state.items.indexWhere((item) => item.product.id == product.id);
    if (existingItemIndex >= 0) {
      final updatedItems = List<CartItem>.from(state.items);
      updatedItems[existingItemIndex] = CartItem(product: product, quantity: quantity);
      state = state.copyWith(items: updatedItems);
    } else {
      // Add new item if it doesn't exist
      addItem(product, quantity: quantity);
    }
  }

  // Clear entire cart
  void clearCart() {
    state = const CartState();
  }

  // Set loading state
  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  // Get cart summary for display
  Map<String, dynamic> getCartSummary() {
    return {
      'itemCount': state.itemCount,
      'totalAmount': state.totalAmount,
      'isEmpty': state.isEmpty,
      'isNotEmpty': state.isNotEmpty,
      'items': state.items,
    };
  }
}

// Provider definition
final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});

// Convenience providers for commonly used values
final cartItemCountProvider = Provider<int>((ref) {
  return ref.watch(cartProvider).itemCount;
});

final cartTotalAmountProvider = Provider<double>((ref) {
  return ref.watch(cartProvider).totalAmount;
});

final cartItemsProvider = Provider<List<CartItem>>((ref) {
  return ref.watch(cartProvider).items;
});

final cartIsEmptyProvider = Provider<bool>((ref) {
  return ref.watch(cartProvider).isEmpty;
});

final cartIsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(cartProvider).isLoading;
});

// Provider to check if specific product is in cart
final productInCartProvider = Provider.family<bool, Product>((ref, product) {
  return ref.watch(cartProvider).isInCart(product);
});

// Provider to get quantity of specific product in cart
final productQuantityProvider = Provider.family<int, Product>((ref, product) {
  return ref.watch(cartProvider).getQuantity(product);
});

// Provider to get total amount for specific product in cart
final productTotalProvider = Provider.family<double, Product>((ref, product) {
  return ref.watch(cartProvider).getItemTotal(product);
});