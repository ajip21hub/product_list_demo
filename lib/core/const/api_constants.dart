/// API Configuration Constants
/// Contains all API-related settings, endpoints, and network configuration

class APIConstants {
  // Base URL Configuration
  static const String baseUrl = 'https://dummyjson.com';
  static const String apiVersion = 'v1';
  static const String timeoutDuration = '30s';

  // API Endpoints
  static const String productsEndpoint = '/products';
  static const String categoriesEndpoint = '/products/categories';
  static const String productsByCategoryEndpoint = '/products/category';
  static const String singleProductEndpoint = '/products';
  static const String searchEndpoint = '/products/search';
  static const String authEndpoint = '/auth';
  static const String refreshTokenEndpoint = '/auth/refresh';
  static const String usersEndpoint = '/users';

  // Authentication
  static const String tokenHeaderKey = 'Authorization';
  static const String tokenPrefix = 'Bearer ';
  static const String refreshTokenKey = 'refresh_token';
  static const String accessTokenKey = 'access_token';
  static const Duration tokenExpiry = Duration(hours: 24);
  static const Duration refreshBuffer = Duration(minutes: 5);

  // Request Configuration
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'User-Agent': 'ProductListDemo/1.0.0',
  };

  // Rate Limiting
  static const int maxRequestsPerMinute = 60;
  static const int maxRequestsPerHour = 1000;
  static const Duration rateLimitResetDuration = Duration(minutes: 1);

  // Retry Configuration
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 1);
  static const Duration retryBackoffMultiplier = Duration(seconds: 2);
  static const List<int> retryableStatusCodes = [408, 429, 500, 502, 503, 504];

  // Connection Configuration
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
  static const bool followRedirects = true;
  static const int maxRedirects = 5;

  // Cache Configuration
  static const Duration defaultCacheDuration = Duration(minutes: 5);
  static const Duration longCacheDuration = Duration(hours: 1);
  static const Duration shortCacheDuration = Duration(minutes: 1);
  static const int maxCacheSize = 50; // MB

  // Pagination
  static const String limitParam = 'limit';
  static const String skipParam = 'skip';
  static const int defaultLimit = 20;
  static const int maxLimit = 100;
  static const int defaultSkip = 0;

  // Search
  static const String searchQueryParam = 'q';
  static const int minSearchQueryLength = 2;
  static const int maxSearchResults = 50;

  // Sorting
  static const String sortParam = 'sortBy';
  static const String orderParam = 'order';
  static const String ascendingOrder = 'asc';
  static const String descendingOrder = 'desc';

  // Filtering
  static const String categoryParam = 'category';
  static const String priceMinParam = 'minPrice';
  static const String priceMaxParam = 'maxPrice';
  static const String ratingParam = 'rating';

  // Error Messages
  static const String networkErrorMessage = 'Network connection error. Please check your internet connection.';
  static const String timeoutErrorMessage = 'Request timed out. Please try again.';
  static const String serverErrorMessage = 'Server error. Please try again later.';
  static const String unauthorizedMessage = 'Authentication failed. Please log in again.';
  static const String forbiddenMessage = 'Access denied. You don\'t have permission to perform this action.';
  static const String notFoundMessage = 'The requested resource was not found.';
  static const String rateLimitMessage = 'Too many requests. Please try again later.';
  static const String defaultErrorMessage = 'An error occurred. Please try again.';

  // HTTP Status Codes
  static const int statusOk = 200;
  static const int statusCreated = 201;
  static const int statusNoContent = 204;
  static const int statusBadRequest = 400;
  static const int statusUnauthorized = 401;
  static const int statusForbidden = 403;
  static const int statusNotFound = 404;
  static const int statusMethodNotAllowed = 405;
  static const int statusConflict = 409;
  static const int statusTooManyRequests = 429;
  static const int statusInternalServerError = 500;
  static const int statusBadGateway = 502;
  static const int statusServiceUnavailable = 503;
  static const int statusGatewayTimeout = 504;

  // Content Types
  static const String contentTypeJson = 'application/json';
  static const String contentTypeFormData = 'multipart/form-data';
  static const String contentTypeUrlEncoded = 'application/x-www-form-urlencoded';

  // Logging
  static const bool enableNetworkLogging = true;
  static const bool logRequestHeaders = true;
  static const bool logResponseHeaders = true;
  static const bool logRequestBody = false; // Set to false for production
  static const bool logResponseBody = false; // Set to false for production

  // Development vs Production
  static const bool isProduction = false;
  static const String environment = 'development';
}