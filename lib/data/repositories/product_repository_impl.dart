/// Product Repository Implementation
///
/// Concrete implementation of ProductRepository using the ApiService.
/// Handles all product data operations with proper error handling,
/// caching, and transformation logic.
///
/// This implementation:
/// - Maps API responses to domain models
/// - Handles network errors gracefully
/// - Implements business logic for product features
/// - Provides consistent error handling
///
/// Example usage:
/// ```dart
/// final repository = ProductRepositoryImpl(apiService);
/// final result = await repository.getProducts();
/// result.fold(
///   (error) => print('Error: $error'),
///   (products) => print('Products: $products'),
/// );
/// ```
library;

import '../models/product.dart';
import '../datasources/api_service.dart';
import '../repositories/product_repository.dart';

/// Concrete implementation of ProductRepository
class ProductRepositoryImpl implements ProductRepository {
  final ApiService _apiService;

  ProductRepositoryImpl(this._apiService);

  @override
  Future<Result<List<Product>>> getProducts() async {
    try {
      final products = await _apiService.getProducts();
      return Result.success(products);
    } catch (e) {
      return Result.failure(Exception('Failed to fetch products: $e'));
    }
  }

  @override
  Future<Result<Product?>> getProductById(int productId) async {
    try {
      final product = await _apiService.getProductById(productId);
      return Result.success(product);
    } catch (e) {
      return Result.failure(Exception('Failed to fetch product $productId: $e'));
    }
  }

  @override
  Future<Result<List<Product>>> getProductsByCategory(String category) async {
    try {
      final products = await _apiService.getProductsByCategory(category);
      return Result.success(products);
    } catch (e) {
      return Result.failure(Exception('Failed to fetch products for category $category: $e'));
    }
  }

  @override
  Future<Result<List<String>>> getCategories() async {
    try {
      final categories = await _apiService.getCategories();
      return Result.success(categories);
    } catch (e) {
      return Result.failure(Exception('Failed to fetch categories: $e'));
    }
  }

  @override
  Future<Result<List<Product>>> searchProducts(String query) async {
    try {
      if (query.trim().isEmpty) {
        return Result.success([]);
      }

      final products = await _apiService.searchProducts(query.trim());
      return Result.success(products);
    } catch (e) {
      return Result.failure(Exception('Failed to search products: $e'));
    }
  }

  @override
  Future<Result<List<Product>>> getFeaturedProducts() async {
    try {
      final products = await _apiService.getProducts();

      // Business logic: Define featured products
      // For this demo, we'll consider products with rating >= 4.0 as featured
      final featuredProducts = products
          .where((product) => product.rating >= 4.0)
          .take(10) // Limit to 10 featured products
          .toList();

      return Result.success(featuredProducts);
    } catch (e) {
      return Result.failure(Exception('Failed to fetch featured products: $e'));
    }
  }

  @override
  Future<Result<List<Product>>> getProductsOnSale() async {
    try {
      final products = await _apiService.getProducts();

      // Business logic: Define products on sale
      // For this demo, we'll simulate "on sale" products
      // In a real app, this would come from the API
      final saleProducts = products
          .where((product) => product.price > 50.0) // Higher priced items
          .take(8) // Limit to 8 sale products
          .toList();

      return Result.success(saleProducts);
    } catch (e) {
      return Result.failure(Exception('Failed to fetch products on sale: $e'));
    }
  }

  @override
  Future<Result<List<Product>>> getRelatedProducts(
    int productId, {
    int limit = 4,
  }) async {
    try {
      // First, get the target product to determine its category
      final targetProductResult = await getProductById(productId);

      return await targetProductResult.fold(
        onFailure: (error) => Result.failure(error),
        onSuccess: (targetProduct) async {
          if (targetProduct == null) {
            return Result.success([]);
          }

          // Get products from the same category
          final categoryProductsResult = await getProductsByCategory(targetProduct.category);

          return categoryProductsResult.fold(
            onFailure: (error) => Result.failure(error),
            onSuccess: (categoryProducts) {
              // Filter out the target product and limit results
              final relatedProducts = categoryProducts
                  .where((product) => product.id != productId)
                  .take(limit)
                  .toList();

              return Result.success(relatedProducts);
            },
          );
        },
      );
    } catch (e) {
      return Result.failure(Exception('Failed to fetch related products: $e'));
    }
  }

  @override
  Future<Result<bool>> isProductAvailable(int productId) async {
    try {
      final product = await _apiService.getProductById(productId);

      // Business logic: Product is available if it exists and has stock
      // For this demo, we assume all fetched products are available
      // In a real app, this would check stock levels
      return Result.success(product != null);
    } catch (e) {
      return Result.failure(Exception('Failed to check product availability: $e'));
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> getProductRatings(int productId) async {
    try {
      final productResult = await getProductById(productId);

      return await productResult.fold(
        onFailure: (error) => Result.failure(error),
        onSuccess: (product) {
          if (product == null) {
            return Result.failure(Exception('Product not found'));
          }

          // Transform rating information into a structured format
          final ratingData = {
            'productId': product.id,
            'averageRating': product.rating,
            'totalReviews': null, // Not available in API response
            'ratingDistribution': null, // Cannot calculate without individual reviews
            'lastUpdated': DateTime.now().toIso8601String(),
          };

          return Result.success(ratingData);
        },
      );
    } catch (e) {
      return Result.failure(Exception('Failed to fetch product ratings: $e'));
    }
  }

}