import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/product.dart';
import '../../core/localization/app_localizations.dart';
import '../providers/cart_provider_riverpod.dart';
import '../providers/wishlist_provider_riverpod.dart';

class ProductDetailScreen extends ConsumerWidget {
  final Product product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, ref, localizations),
          SliverToBoxAdapter(
            child: _buildProductInfo(context, localizations),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context, ref, localizations),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, WidgetRef ref, AppLocalizations localizations) {
    final wishlistState = ref.watch(wishlistProvider);
    final cartState = ref.watch(cartProvider);
    final isFavorite = wishlistState.isFavorite(product);
    final cartItemCount = cartState.itemCount;

    return SliverAppBar(
      expandedHeight: 400,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Hero(
          tag: 'product-${product.id}',
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
            ),
            child: Image.network(
              product.image ?? product.thumbnail,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(
                      Icons.image_not_supported,
                      size: 100,
                      color: Colors.grey,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      actions: [
        Stack(
          children: [
            IconButton(
              onPressed: () => _showCartSnackbar(context, ref, localizations),
              icon: const Icon(Icons.shopping_cart),
            ),
            if (cartItemCount > 0)
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
                    '$cartItemCount',
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
            final wishlistNotifier = ref.read(wishlistProvider.notifier);
            wishlistNotifier.toggleFavorite(product);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  isFavorite
                    ? localizations.translate('product.removedFromWishlist')
                    : localizations.translate('product.addedToWishlist'),
                ),
                duration: const Duration(seconds: 1),
              ),
            );
          },
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.red : null,
          ),
        ),
      ],
    );
  }

  Widget _buildProductInfo(BuildContext context, AppLocalizations localizations) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Text(
              product.category.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
                letterSpacing: 0.5,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Product title
          Text(
            product.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Rating and reviews
          Row(
            children: [
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < product.rating.floor()
                        ? Icons.star
                        : index < product.rating
                            ? Icons.star_half
                            : Icons.star_border,
                    color: Colors.amber[600],
                    size: 20,
                  );
                }),
              ),
              const SizedBox(width: 8),
              Text(
                '${product.rating.toStringAsFixed(1)}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Price
          Text(
            '\$${product.price.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.green[700],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Description section
          Text(
            localizations.translate('product.description'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Text(
              product.description,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
          ),
          
          const SizedBox(height: 100), // Space for bottom bar
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, WidgetRef ref, AppLocalizations localizations) {
    final cartState = ref.watch(cartProvider);
    final wishlistState = ref.watch(wishlistProvider);
    final isInCart = cartState.isInCart(product);
    final isFavorite = wishlistState.isFavorite(product);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Add to wishlist button
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                onPressed: () {
                  final wishlistNotifier = ref.read(wishlistProvider.notifier);
                  wishlistNotifier.toggleFavorite(product);
                },
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : Colors.grey[600],
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Add to cart button
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  final cartNotifier = ref.read(cartProvider.notifier);
                  if (isInCart) {
                    _showCartSnackbar(context, ref, localizations);
                  } else {
                    cartNotifier.addItem(product);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(localizations.translate('product.addedToCart')),
                        duration: const Duration(seconds: 2),
                        action: SnackBarAction(
                          label: localizations.translate('cart.undo'),
                          onPressed: () {
                            cartNotifier.removeItem(product);
                          },
                        ),
                      ),
                    );
                  }
                },
                icon: Icon(isInCart ? Icons.shopping_cart : Icons.add_shopping_cart),
                label: Text(isInCart
                    ? localizations.translate('product.viewCart')
                    : localizations.translate('product.addToCart')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isInCart ? Colors.green : Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCartSnackbar(BuildContext context, WidgetRef ref, AppLocalizations localizations) {
    final cartState = ref.read(cartProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${localizations.translate('cart.title')}: ${cartState.itemCount} ${localizations.translate(cartState.itemCount == 1 ? 'cart.item' : 'cart.items')} - \$${cartState.totalAmount.toStringAsFixed(2)}',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}