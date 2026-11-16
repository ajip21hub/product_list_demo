// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_provider_riverpod.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Lab 1B: dulu `StateNotifier<CartState>` + `StateNotifierProvider`.
/// Sekarang Notifier + codegen: state awal dibuat di build(), provider
/// `cartProvider` di-generate. keepAlive agar isi keranjang tidak hilang
/// saat tidak ada widget yang menontonnya.

@ProviderFor(Cart)
final cartProvider = CartProvider._();

/// Lab 1B: dulu `StateNotifier<CartState>` + `StateNotifierProvider`.
/// Sekarang Notifier + codegen: state awal dibuat di build(), provider
/// `cartProvider` di-generate. keepAlive agar isi keranjang tidak hilang
/// saat tidak ada widget yang menontonnya.
final class CartProvider extends $NotifierProvider<Cart, CartState> {
  /// Lab 1B: dulu `StateNotifier<CartState>` + `StateNotifierProvider`.
  /// Sekarang Notifier + codegen: state awal dibuat di build(), provider
  /// `cartProvider` di-generate. keepAlive agar isi keranjang tidak hilang
  /// saat tidak ada widget yang menontonnya.
  CartProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cartProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cartHash();

  @$internal
  @override
  Cart create() => Cart();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CartState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CartState>(value),
    );
  }
}

String _$cartHash() => r'7e61dc53421a254d96787a607c62951d7f43cdd8';

/// Lab 1B: dulu `StateNotifier<CartState>` + `StateNotifierProvider`.
/// Sekarang Notifier + codegen: state awal dibuat di build(), provider
/// `cartProvider` di-generate. keepAlive agar isi keranjang tidak hilang
/// saat tidak ada widget yang menontonnya.

abstract class _$Cart extends $Notifier<CartState> {
  CartState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<CartState, CartState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CartState, CartState>,
              CartState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(cartItemCount)
final cartItemCountProvider = CartItemCountProvider._();

final class CartItemCountProvider extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  CartItemCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cartItemCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cartItemCountHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return cartItemCount(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$cartItemCountHash() => r'0b70bbbd76f62143257d8582f5569f843afb1bfd';

@ProviderFor(cartTotalAmount)
final cartTotalAmountProvider = CartTotalAmountProvider._();

final class CartTotalAmountProvider
    extends $FunctionalProvider<double, double, double>
    with $Provider<double> {
  CartTotalAmountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cartTotalAmountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cartTotalAmountHash();

  @$internal
  @override
  $ProviderElement<double> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  double create(Ref ref) {
    return cartTotalAmount(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$cartTotalAmountHash() => r'c0e94746e073fc1b297ce61b02f18a3fbf2ae622';

@ProviderFor(cartItems)
final cartItemsProvider = CartItemsProvider._();

final class CartItemsProvider
    extends $FunctionalProvider<List<CartItem>, List<CartItem>, List<CartItem>>
    with $Provider<List<CartItem>> {
  CartItemsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cartItemsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cartItemsHash();

  @$internal
  @override
  $ProviderElement<List<CartItem>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<CartItem> create(Ref ref) {
    return cartItems(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<CartItem> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<CartItem>>(value),
    );
  }
}

String _$cartItemsHash() => r'f88d88b05ea9edf7d8a58d84de2456809302b8ae';

@ProviderFor(cartIsEmpty)
final cartIsEmptyProvider = CartIsEmptyProvider._();

final class CartIsEmptyProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  CartIsEmptyProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cartIsEmptyProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cartIsEmptyHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return cartIsEmpty(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$cartIsEmptyHash() => r'1f2a603cf083b768e849d23a9a686e8d41f48ee5';

@ProviderFor(cartIsLoading)
final cartIsLoadingProvider = CartIsLoadingProvider._();

final class CartIsLoadingProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  CartIsLoadingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cartIsLoadingProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cartIsLoadingHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return cartIsLoading(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$cartIsLoadingHash() => r'5a868f98e5635212a94e8f6852c0d0a557890dae';

/// Family lama `Provider.family<bool, Product>` menjadi parameter fungsi.

@ProviderFor(productInCart)
final productInCartProvider = ProductInCartFamily._();

/// Family lama `Provider.family<bool, Product>` menjadi parameter fungsi.

final class ProductInCartProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Family lama `Provider.family<bool, Product>` menjadi parameter fungsi.
  ProductInCartProvider._({
    required ProductInCartFamily super.from,
    required Product super.argument,
  }) : super(
         retry: null,
         name: r'productInCartProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$productInCartHash();

  @override
  String toString() {
    return r'productInCartProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    final argument = this.argument as Product;
    return productInCart(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ProductInCartProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$productInCartHash() => r'a2b2bb75a829a9c528f60931d99daf447a751f56';

/// Family lama `Provider.family<bool, Product>` menjadi parameter fungsi.

final class ProductInCartFamily extends $Family
    with $FunctionalFamilyOverride<bool, Product> {
  ProductInCartFamily._()
    : super(
        retry: null,
        name: r'productInCartProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Family lama `Provider.family<bool, Product>` menjadi parameter fungsi.

  ProductInCartProvider call(Product product) =>
      ProductInCartProvider._(argument: product, from: this);

  @override
  String toString() => r'productInCartProvider';
}

@ProviderFor(productQuantity)
final productQuantityProvider = ProductQuantityFamily._();

final class ProductQuantityProvider extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  ProductQuantityProvider._({
    required ProductQuantityFamily super.from,
    required Product super.argument,
  }) : super(
         retry: null,
         name: r'productQuantityProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$productQuantityHash();

  @override
  String toString() {
    return r'productQuantityProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    final argument = this.argument as Product;
    return productQuantity(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ProductQuantityProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$productQuantityHash() => r'57e8e738a4a78ed85e989aef8c9d653c2a1d9283';

final class ProductQuantityFamily extends $Family
    with $FunctionalFamilyOverride<int, Product> {
  ProductQuantityFamily._()
    : super(
        retry: null,
        name: r'productQuantityProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ProductQuantityProvider call(Product product) =>
      ProductQuantityProvider._(argument: product, from: this);

  @override
  String toString() => r'productQuantityProvider';
}

@ProviderFor(productTotal)
final productTotalProvider = ProductTotalFamily._();

final class ProductTotalProvider
    extends $FunctionalProvider<double, double, double>
    with $Provider<double> {
  ProductTotalProvider._({
    required ProductTotalFamily super.from,
    required Product super.argument,
  }) : super(
         retry: null,
         name: r'productTotalProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$productTotalHash();

  @override
  String toString() {
    return r'productTotalProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<double> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  double create(Ref ref) {
    final argument = this.argument as Product;
    return productTotal(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ProductTotalProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$productTotalHash() => r'a794df8e0417702a77f8e7b00789be1b18afc4d3';

final class ProductTotalFamily extends $Family
    with $FunctionalFamilyOverride<double, Product> {
  ProductTotalFamily._()
    : super(
        retry: null,
        name: r'productTotalProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ProductTotalProvider call(Product product) =>
      ProductTotalProvider._(argument: product, from: this);

  @override
  String toString() => r'productTotalProvider';
}
