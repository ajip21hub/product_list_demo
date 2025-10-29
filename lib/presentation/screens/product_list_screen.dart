import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/product.dart';
import '../providers/cart_provider_riverpod.dart';
import '../providers/wishlist_provider_riverpod.dart';
import '../providers/product_list_provider.dart';
import '../../core/const/constants.dart';
import '../../core/localization/app_localizations.dart';
import '../widgets/state_widgets.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';
import 'wishlist_screen.dart';

class ProductListScreen extends ConsumerWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get localizations instance
    final localizations = AppLocalizations.of(context)!;

    // Watch the product list state
    final productListState = ref.watch(productListProvider);
    final productListNotifier = ref.read(productListProvider.notifier);

    // Watch cart and wishlist states
    final cartState = ref.watch(cartProvider);
    final wishlistState = ref.watch(wishlistProvider);

    // Extract state values
    final products = productListState.products;
    final categories = productListState.categories;
    final selectedCategory = productListState.selectedCategory;
    final isLoading = productListState.isLoading;
    final error = productListState.error;

    // Initialize data on first build
    ref.listen(productListProvider, (previous, next) {
      // Only load data if it's the first time and no data exists
      if (previous == null && next.products.isEmpty && !next.isLoading && next.error == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          productListNotifier.loadProducts();
        });
      }
    });

    // Initial load if state is empty
    if (products.isEmpty && !isLoading && error == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        productListNotifier.loadProducts();
      });
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          localizations.translate('product.title'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Wishlist button
          Stack(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WishlistScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.favorite),
              ),
              if (wishlistState.itemCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${wishlistState.itemCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          // Cart button
          Stack(
            children: [
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${localizations.translate('cart.title')}: ${cartState.itemCount} ${localizations.translate(cartState.itemCount == 1 ? 'cart.item' : 'cart.items')} - \$${cartState.totalAmount.toStringAsFixed(2)}',
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.shopping_cart),
              ),
              if (cartState.itemCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${cartState.itemCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            onPressed: () {
              SnackBar snackBar = SnackBar(
                content: Text(localizations.translate('profile.featureComingSoon')),
                duration: const Duration(seconds: 2),
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            },
            icon: const Icon(Icons.person),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCategoryFilter(context, localizations, categories, selectedCategory, productListNotifier),
          Expanded(child: _buildBody(context, localizations, products, isLoading, error, productListNotifier)),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter(BuildContext context, AppLocalizations localizations, List<String> categories, String selectedCategory, ProductListNotifier productListNotifier) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.grey[100],
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: categories.length + 1,
        itemBuilder: (context, index) {
          final category = index == 0 ? localizations.translate('product.all') : categories[index - 1];
          final isSelected = selectedCategory == category;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  productListNotifier.filterByCategory(category);
                }
              },
              backgroundColor: Colors.white,
              selectedColor: Colors.blue[200],
              labelStyle: TextStyle(
                color: isSelected ? Colors.blue[800] : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, AppLocalizations localizations, List<Product> products, bool isLoading, String? error, ProductListNotifier productListNotifier) {
    if (isLoading) {
      return _buildLoadingState(localizations);
    }

    if (error != null) {
      return _buildErrorState(localizations, error, productListNotifier);
    }

    if (products.isEmpty) {
      return _buildEmptyState(localizations);
    }

    return _buildProductGrid(context, products, productListNotifier);
  }

  Widget _buildLoadingState(AppLocalizations localizations) {
    return LoadingStateWidget(
      message: localizations.translate('product.loading'),
    );
  }

  Widget _buildErrorState(AppLocalizations localizations, String error, ProductListNotifier productListNotifier) {
    return ErrorStateWidget(
      message: localizations.translate('product.error', args: {'error': error}),
      onRetry: () => productListNotifier.loadProducts(),
    );
  }

  Widget _buildEmptyState(AppLocalizations localizations) {
    return EmptyStateWidget(
      message: localizations.translate('product.noProducts'),
      icon: Icons.shopping_bag_outlined,
    );
  }

  Widget _buildProductGrid(BuildContext context, List<Product> products, ProductListNotifier productListNotifier) {
    return RefreshIndicator(
      onRefresh: () => productListNotifier.refresh(),
      child: GridView.builder(
        padding: UIConstants.paddingSmall,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: GridConstants.productGridCrossAxisCount,
          childAspectRatio: GridConstants.productGridChildAspectRatio,
          crossAxisSpacing: GridConstants.productGridCrossAxisSpacing,
          mainAxisSpacing: GridConstants.productGridMainAxisSpacing,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          return ProductCard(
            product: products[index],
            onTap: () => _navigateToProductDetail(context, products[index]),
          );
        },
      ),
    );
  }

  void _navigateToProductDetail(BuildContext context, Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(product: product),
      ),
    );
  }
}
