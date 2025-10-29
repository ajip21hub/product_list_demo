/// Product Repository Interface
///
/// Abstract interface defining the contract for product data operations.
/// This follows the Repository pattern, providing a clean abstraction
/// between the domain layer and data sources.
///
/// Implementations should handle:
/// - API calls to product endpoints
/// - Caching strategies
/// - Error handling and transformation
/// - Offline support (future enhancement)
///
/// Example usage:
/// ```dart
/// final repository = ProductRepositoryImpl(apiService);
/// final products = await repository.getProducts();
/// ```

import '../models/product.dart';

/// Simple Result class for repository operations
class Result<T> {
  final T? data;
  final Exception? error;
  final bool isSuccess;

  const Result._({this.data, this.error, required this.isSuccess});

  factory Result.success(T data) => Result._(data: data, isSuccess: true);
  factory Result.failure(Exception error) => Result._(error: error, isSuccess: false);

  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(Exception error) onFailure,
  }) {
    if (isSuccess) {
      return onSuccess(data!);
    } else {
      return onFailure(error!);
    }
  }

  bool get isFailure => !isSuccess;
}

/// Abstract repository interface for product operations
abstract class ProductRepository {
  /// Fetch all products from the data source
  ///
  /// Returns [Result<List<Product>>] with products or error
  Future<Result<List<Product>>> getProducts();

  /// Fetch a single product by ID
  ///
  /// [productId] - The ID of the product to fetch
  /// Returns [Result<Product?>] with product or error
  Future<Result<Product?>> getProductById(int productId);

  /// Fetch products by category
  ///
  /// [category] - The category to filter products by
  /// Returns [Result<List<Product>>] with products or error
  Future<Result<List<Product>>> getProductsByCategory(String category);

  /// Get all available categories
  ///
  /// Returns [Result<List<String>>] with categories or error
  Future<Result<List<String>>> getCategories();

  /// Search products by query
  ///
  /// [query] - The search query string
  /// Returns [Result<List<Product>>] with search results or error
  Future<Result<List<Product>>> searchProducts(String query);

  /// Get featured products (business logic implementation)
  ///
  /// Returns [Result<List<Product>>] with featured products or error
  Future<Result<List<Product>>> getFeaturedProducts();

  /// Get products on sale (business logic implementation)
  ///
  /// Returns [Result<List<Product>>] with sale products or error
  Future<Result<List<Product>>> getProductsOnSale();

  /// Get related products for a given product
  ///
  /// [productId] - The product ID to find related products for
  /// [limit] - Maximum number of related products to return
  /// Returns [Result<List<Product>>] with related products or error
  Future<Result<List<Product>>> getRelatedProducts(
    int productId, {
    int limit = 4,
  });

  /// Check product availability
  ///
  /// [productId] - The product ID to check
  /// Returns [Result<bool>] indicating availability or error
  Future<Result<bool>> isProductAvailable(int productId);

  /// Get product ratings and reviews summary
  ///
  /// [productId] - The product ID to get ratings for
  /// Returns [Result<Map<String, dynamic>>] with rating data or error
  Future<Result<Map<String, dynamic>>> getProductRatings(int productId);
}

/// Result type helper for repository operations
typedef RepositoryResult<T> = Future<Result<T>>;