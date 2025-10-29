import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/product.dart';
import '../../core/localization/app_localizations.dart';
import '../providers/wishlist_provider_riverpod.dart';
import '../providers/cart_provider_riverpod.dart';
import 'product_detail_screen.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context)!;
    final wishlistState = ref.watch(wishlistProvider);
    final wishlistItems = wishlistState.items;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          localizations.translate('wishlist.title'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: wishlistItems.isEmpty
          ? _buildEmptyWishlist(localizations)
          : RefreshIndicator(
              onRefresh: () async {
                // Refresh wishlist if needed
              },
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: wishlistItems.length,
                itemBuilder: (context, index) {
                  return WishlistProductCard(
                    product: wishlistItems[index],
                    onRemove: () => _removeFromWishlist(context, ref, wishlistItems[index], localizations),
                    onAddToCart: () => _addToCart(context, ref, wishlistItems[index], localizations),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildEmptyWishlist(AppLocalizations localizations) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 120,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            localizations.translate('wishlist.empty'),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            localizations.translate('wishlist.emptyMessage'),
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _removeFromWishlist(BuildContext context, WidgetRef ref, Product product, AppLocalizations localizations) {
    final wishlistNotifier = ref.read(wishlistProvider.notifier);
    wishlistNotifier.toggleFavorite(product);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(localizations.translate('wishlist.itemRemoved')),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: localizations.translate('wishlist.undo'),
          onPressed: () {
            wishlistNotifier.toggleFavorite(product);
          },
        ),
      ),
    );
  }

  void _addToCart(BuildContext context, WidgetRef ref, Product product, AppLocalizations localizations) {
    final cartNotifier = ref.read(cartProvider.notifier);
    final cartState = ref.read(cartProvider);

    if (!cartState.isInCart(product)) {
      cartNotifier.addItem(product);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.translate('wishlist.itemAddedToCart')),
          duration: const Duration(seconds: 2),
          action: SnackBarAction(
            label: localizations.translate('wishlist.undo'),
            onPressed: () {
              cartNotifier.removeItem(product);
            },
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.translate('wishlist.alreadyInCart')),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }
}

class WishlistProductCard extends ConsumerWidget {
  final Product product;
  final VoidCallback onRemove;
  final VoidCallback onAddToCart;

  const WishlistProductCard({
    super.key,
    required this.product,
    required this.onRemove,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);
    final isInCart = cartState.isInCart(product);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(product: product),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      color: Colors.grey[100],
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: Hero(
                        tag: 'wishlist-product-${product.id}',
                        child: Image.network(
                          product.image ?? product.thumbnail,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[200],
                              child: const Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  // Remove button overlay
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        padding: EdgeInsets.zero,
                        onPressed: onRemove,
                        icon: Icon(
                          Icons.favorite,
                          color: Colors.red[600],
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.category,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '\$${product.price.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[700],
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    size: 14,
                                    color: Colors.amber[600],
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    product.rating.toStringAsFixed(1),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: isInCart
                                ? Colors.green[50]
                                : Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isInCart ? Colors.green : Colors.blue,
                            ),
                          ),
                          child: IconButton(
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                            padding: EdgeInsets.zero,
                            onPressed: isInCart ? null : onAddToCart,
                            icon: Icon(
                              isInCart
                                  ? Icons.shopping_cart
                                  : Icons.add_shopping_cart,
                              color: isInCart ? Colors.green : Colors.blue,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}