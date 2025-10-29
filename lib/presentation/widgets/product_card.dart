/// Reusable Product Card Widget
///
/// A customizable product card that displays product information with consistent design
/// across the application. Supports wishlist toggle, cart management, and navigation.
/// Uses Riverpod for optimized state management and performance.
///
/// Example usage:
/// ```dart
/// ProductCard(
///   product: product,
///   onTap: () => Navigator.push(...),
///   showCartButton: true,
///   showWishlistButton: true,
/// )
/// ```

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/product.dart';
import '../../core/const/constants.dart';
import '../providers/cart_provider_riverpod.dart';
import '../providers/wishlist_provider_riverpod.dart';
import 'rating_display_widget.dart';

class ProductCard extends ConsumerWidget {
  final Product product;
  final VoidCallback? onTap;
  final bool showCartButton;
  final bool showWishlistButton;
  final double? aspectRatio;
  final double? elevation;
  final bool enableHero;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.showCartButton = true,
    this.showWishlistButton = true,
    this.aspectRatio,
    this.elevation,
    this.enableHero = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch specific values using selectors for optimized rebuilds
    final isFavorite = ref.watch(isProductFavoritedProvider(product));
    final isInCart = ref.watch(productInCartProvider(product));
    final cartQuantity = ref.watch(productQuantityProvider(product));

    return Card(
      elevation: elevation ?? UIConstants.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: UIConstants.borderRadiusLarge,
      ),
      child: InkWell(
        onTap: onTap ?? () => _navigateToDetail(context),
        borderRadius: UIConstants.borderRadiusLarge,
        child: _buildCardContent(context, ref, isFavorite, isInCart, cartQuantity),
      ),
    );
  }

  Widget _buildCardContent(
    BuildContext context,
    WidgetRef ref,
    bool isFavorite,
    bool isInCart,
    int cartQuantity,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: _buildProductImage(context, ref, isFavorite),
        ),
        Expanded(
          flex: 2,
          child: _buildProductInfo(context, ref, isInCart, cartQuantity),
        ),
      ],
    );
  }

  Widget _buildProductImage(BuildContext context, WidgetRef ref, bool isFavorite) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(UIConstants.radiusLarge),
            ),
            color: Colors.grey[100],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(UIConstants.radiusLarge),
            ),
            child: _buildImageWidget(),
          ),
        ),
        if (showWishlistButton) _buildWishlistButton(context, ref, isFavorite),
      ],
    );
  }

  Widget _buildImageWidget() {
    final imageWidget = Image.network(
      product.image ?? product.thumbnail,
      fit: BoxFit.contain,
      errorBuilder: _buildErrorImage,
      loadingBuilder: _buildLoadingImage,
    );

    if (enableHero) {
      return Hero(
        tag: 'product-${product.id}',
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Widget _buildErrorImage(BuildContext context, Object error, StackTrace? stackTrace) {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported,
              size: 48,
              color: Colors.grey[400],
            ),
            UIConstants.verticalSpaceTiny,
            Text(
              'Image not available',
              style: TextStyle(
                fontSize: UIConstants.fontSizeSmall,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingImage(
    BuildContext context,
    Widget child,
    ImageChunkEvent? loadingProgress,
  ) {
    if (loadingProgress == null) return child;

    return Center(
      child: CircularProgressIndicator(
        value: loadingProgress.expectedTotalBytes != null
            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
            : null,
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[300]!),
      ),
    );
  }

  Widget _buildWishlistButton(BuildContext context, WidgetRef ref, bool isFavorite) {
    return Positioned(
      top: UIConstants.spacingSmall,
      right: UIConstants.spacingSmall,
      child: _buildFloatingButton(
        icon: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          color: isFavorite ? Colors.red : Colors.grey[600],
          size: UIConstants.iconSizeMedium,
        ),
        onPressed: () => _toggleWishlist(context, ref),
        backgroundColor: Colors.white,
      ),
    );
  }

  Widget _buildFloatingButton({
    required Widget icon,
    required VoidCallback onPressed,
    Color? backgroundColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        shape: BoxShape.circle,
        boxShadow: UIConstants.cardShadow,
      ),
      child: IconButton(
        constraints: const BoxConstraints(
          minWidth: 32,
          minHeight: 32,
        ),
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        icon: icon,
      ),
    );
  }

  Widget _buildProductInfo(
    BuildContext context,
    WidgetRef ref,
    bool isInCart,
    int cartQuantity,
  ) {
    return Padding(
      padding: UIConstants.paddingSmall,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProductTitle(),
          UIConstants.verticalSpaceMini,
          _buildProductCategory(),
          const Spacer(),
          _buildPriceAndRating(),
          if (showCartButton) ...[
            UIConstants.verticalSpaceSmall,
            _buildCartButton(context, ref, isInCart, cartQuantity),
          ],
        ],
      ),
    );
  }

  Widget _buildProductTitle() {
    return Text(
      product.title,
      style: TextStyle(
        fontSize: UIConstants.fontSizeSmall,
        fontWeight: FontWeight.bold,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildProductCategory() {
    return Text(
      product.category,
      style: TextStyle(
        fontSize: UIConstants.fontSizeMicro,
        color: Colors.grey[600],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildPriceAndRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPrice(),
              UIConstants.verticalSpaceMini,
              _buildRating(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPrice() {
    return Text(
      '\$${product.price.toStringAsFixed(2)}',
      style: TextStyle(
        fontSize: UIConstants.fontSizeMedium,
        fontWeight: FontWeight.bold,
        color: Colors.green[700],
      ),
    );
  }

  Widget _buildRating() {
    return RatingDisplayWidget(
      rating: product.rating,
      count: null, // Count field no longer exists in API response
      size: RatingDisplaySize.small,
    );
  }

  Widget _buildCartButton(
    BuildContext context,
    WidgetRef ref,
    bool isInCart,
    int cartQuantity,
  ) {
    final buttonColor = isInCart ? Colors.green : Colors.blue;
    final buttonIcon = isInCart ? Icons.shopping_cart : Icons.add_shopping_cart;

    return Container(
      decoration: BoxDecoration(
        color: isInCart ? Colors.green[50] : Colors.blue[50],
        borderRadius: UIConstants.borderRadiusSmall,
        border: Border.all(color: buttonColor),
      ),
      child: IconButton(
        constraints: const BoxConstraints(
          minWidth: 32,
          minHeight: 32,
        ),
        padding: EdgeInsets.zero,
        onPressed: () => _addToCart(context, ref, isInCart),
        icon: Icon(
          buttonIcon,
          color: buttonColor,
          size: UIConstants.iconSizeMedium,
        ),
      ),
    );
  }

  void _navigateToDetail(BuildContext context) {
    // Navigate to product detail screen
    Navigator.pushNamed(context, '/product-detail', arguments: product);
  }

  void _toggleWishlist(BuildContext context, WidgetRef ref) {
    final wishlistNotifier = ref.read(wishlistProvider.notifier);
    wishlistNotifier.toggleFavorite(product);

    // Show feedback message
    final isFavorite = ref.read(isProductFavoritedProvider(product));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isFavorite ? 'Added to wishlist' : 'Removed from wishlist',
        ),
        duration: AppConstants.shortAnimation,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _addToCart(BuildContext context, WidgetRef ref, bool isInCart) {
    if (isInCart) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Already in cart!'),
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final cartNotifier = ref.read(cartProvider.notifier);
    cartNotifier.addItem(product);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Added to cart!'),
        duration: AppConstants.shortAnimation,
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            cartNotifier.removeItem(product);
          },
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}