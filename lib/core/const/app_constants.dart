/// Application-wide constants
/// Contains app metadata, version info, and general configuration

class AppConstants {
  // App Information
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Flutter Product List Demo App';

  // Localized App Name - This will be replaced by translations in the actual app
  // Keep a default for non-localized contexts
  static String get appName => 'Product List Demo'; // This will be overridden by localizations

  // Debug Configuration
  static const bool isDebugMode = true;
  static const bool enableLogging = true;

  // Cache Configuration
  static const Duration cacheExpiry = Duration(hours: 1);
  static const int maxCacheSize = 100; // MB

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 300);
  static const Duration mediumAnimation = Duration(milliseconds: 800);
  static const Duration longAnimation = Duration(seconds: 1);
  static const Duration extraLongAnimation = Duration(seconds: 2);

  // Delays
  static const Duration loadingDelay = Duration(seconds: 1);
  static const Duration debounceDelay = Duration(milliseconds: 500);
  static const Duration retryDelay = Duration(seconds: 2);

  // Constraints
  static const double maxImageWidth = 300.0;
  static const double maxImageHeight = 300.0;
  static const int maxProductNameLength = 50;
  static const int maxDescriptionLength = 200;

  // Bottom Navigation
  static const double bottomNavHeight = 80.0;
  static const double bottomNavIconSize = 24.0;

  // Avatar and Image Sizes
  static const double avatarSize = 100.0;
  static const double avatarSizeSmall = 80.0;
  static const double logoSize = 120.0;

  // Screen Padding
  static const double screenPadding = 24.0;
  static const double cardPadding = 16.0;
  static const double buttonPadding = 20.0;
  static const double smallPadding = 12.0;
  static const double tinyPadding = 8.0;
  static const double miniPadding = 4.0;
  static const double microPadding = 2.0;
}