import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../../core/const/api_constants.dart';

class ApiService {
  static const String baseUrl = APIConstants.baseUrl;

  Future<List<Product>> getProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl${APIConstants.productsEndpoint}'),
      ).timeout(APIConstants.connectionTimeout);

      if (response.statusCode == APIConstants.statusOk) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> data = responseData['products'];
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching products: $e');
    }
  }

  Future<List<Product>> getProductsByCategory(String category) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl${APIConstants.productsByCategoryEndpoint}/$category'),
      ).timeout(APIConstants.connectionTimeout);

      if (response.statusCode == APIConstants.statusOk) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> data = responseData['products'];
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load products by category: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching products by category: $e');
    }
  }

  Future<List<String>> getCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl${APIConstants.categoriesEndpoint}'),
      ).timeout(APIConstants.connectionTimeout);

      if (response.statusCode == APIConstants.statusOk) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((category) => category['name']?.toString() ?? 'Unknown').toList();
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
  }

  Future<Product?> getProductById(int productId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl${APIConstants.singleProductEndpoint}/$productId'),
      ).timeout(APIConstants.connectionTimeout);

      if (response.statusCode == APIConstants.statusOk) {
        final dynamic data = json.decode(response.body);
        return Product.fromJson(data);
      } else if (response.statusCode == APIConstants.statusNotFound) {
        return null;
      } else {
        throw Exception('Failed to load product: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching product: $e');
    }
  }

  Future<List<Product>> searchProducts(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl${APIConstants.searchEndpoint}?${APIConstants.searchQueryParam}=$query'),
      ).timeout(APIConstants.connectionTimeout);

      if (response.statusCode == APIConstants.statusOk) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> products = data['products'];
        return products.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching products: $e');
    }
  }
}
