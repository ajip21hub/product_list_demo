import 'package:flutter_dotenv/flutter_dotenv.dart';

/// ===========================================
/// ENVIRONMENT MANAGER SERVICE
/// ===========================================
///
/// 📚 PENJELASAN KELEBIHAN MENGGUNAKAN .ENV:
///
/// ✅ **KEAMANAN**: Credentials tidak ter-expose di source code
///    - Password, API keys, dan sensitive data aman dari version control
///    - Mengurangi risiko security breach
///    - Follow security best practices
///
/// ✅ **FLEXIBILITAS**: Environment-specific configuration
///    - Mudah switch antara development/staging/production
///    - Tidak perlu code deployment untuk ubah konfigurasi
///    - Support multiple environment configurations
///
/// ✅ **MAINTAINABILITY**: Centralized configuration management
///    - Semua konfigurasi dalam satu file .env
///    - Mudah di-update tanpa touch source code
///    - Clear separation antara code dan configuration
///
/// ✅ **COMPLIANCE**: Industry standard practices
///    - Following 12-Factor App methodology
///    - Audit-friendly untuk security compliance
///    - Standard practice dalam modern software development
///
/// ✅ **DEVELOPMENT**: Improved development workflow
///    - Local development tanpa hardcoded values
///    - Mudah testing dengan berbagai configurations
///    - Onboarding developer lebih mudah
///
/// 🚨 CARA PENGGUNAAN:
/// 1. Import service ini: import '../core/services/environment_service.dart';
/// 2. Access values: EnvironmentService.baseUrl, EnvironmentService.isDebug, dll
/// 3. Values otomatis di-load dari .env file saat app start
/// 4. Safe fallback jika environment variable tidak ada
///
class EnvironmentService {
  static bool _isInitialized = false;

  /// Initialize environment service
  ///
  /// 📝 NOTE: Harus dipanggil sebelum menggunakan environment variables
  /// Biasanya dipanggil di main() method sebelum runApp()
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Load .env file from assets
      await dotenv.load(fileName: '.env');
      _isInitialized = true;

      // Debug: Print loaded environment (hanya di debug mode)
      if (isDebug) {
        print('🔧 Environment initialized: $currentEnvironment');
        print('🌐 API Base URL: $baseUrl');
      }
    } catch (e) {
      // Fallback jika .env tidak ada
      print('⚠️ Warning: Failed to load .env file: $e');
      print('📋 Using default values for development');
      _isInitialized = true;
    }
  }

  /// ===========================================
  /// ENVIRONMENT SETTINGS
  /// ===========================================

  /// Current environment (development, staging, production)
  ///
  /// 📝 CONTOH PENGGUNAAN:
  /// ```dart
  /// if (EnvironmentService.currentEnvironment == 'production') {
  ///   // Production-specific logic
  ///   logger.setLevel(Level.WARNING);
  /// } else {
  ///   // Development/staging logic
  ///   logger.setLevel(Level.DEBUG);
  /// }
  /// ```
  static String get currentEnvironment {
    _checkInitialization();
    return dotenv.env['ENVIRONMENT'] ?? 'development';
  }

  /// Debug mode flag
  ///
  /// 💡 KELEBIHAN: Kontrol debug behavior tanpa code changes
  static bool get isDebug {
    _checkInitialization();
    return dotenv.env['IS_DEBUG']?.toLowerCase() == 'true';
  }

  /// Enable logging flag
  static bool get enableLogging {
    _checkInitialization();
    return dotenv.env['ENABLE_LOGGING']?.toLowerCase() == 'true';
  }

  /// Enable API logging flag (for debugging API calls)
  static bool get enableApiLogging {
    _checkInitialization();
    return dotenv.env['ENABLE_API_LOGGING']?.toLowerCase() == 'true';
  }

  /// ===========================================
  /// API CONFIGURATION
  /// ===========================================

  /// Base URL untuk API
  ///
  /// 🚨 KEAMANAN: API endpoint tidak lagi hardcoded di source code
  /// 📝 CONTOH PENGGUNAAN:
  /// ```dart
  /// final url = Uri.parse('${EnvironmentService.baseUrl}/products');
  /// ```
  static String get baseUrl {
    _checkInitialization();
    return dotenv.env['API_BASE_URL'] ?? 'https://dummyjson.com';
  }

  /// API version
  static String get apiVersion {
    _checkInitialization();
    return dotenv.env['API_VERSION'] ?? 'v1';
  }

  /// Request timeout in seconds
  ///
  /// 💡 KELEBIHAN: Timeout bisa disesuaikan per environment
  static int get requestTimeoutSeconds {
    _checkInitialization();
    return int.tryParse(dotenv.env['REQUEST_TIMEOUT_SECONDS'] ?? '') ?? 30;
  }

  /// Maximum retry attempts
  static int get maxRetries {
    _checkInitialization();
    return int.tryParse(dotenv.env['MAX_RETRIES'] ?? '') ?? 3;
  }

  /// Connection timeout in seconds
  static int get connectionTimeoutSeconds {
    _checkInitialization();
    return int.tryParse(dotenv.env['CONNECTION_TIMEOUT_SECONDS'] ?? '') ?? 10;
  }

  /// ===========================================
  /// AUTHENTICATION CREDENTIALS
  /// ===========================================

  /// Demo username untuk development
  ///
  /// 🚨 KEAMANAN: Credentials tidak lagi hardcoded di source code!
  /// 💡 KELEBIHAN: Mudah rotate credentials tanpa code deployment
  static String get demoUsername {
    _checkInitialization();
    return dotenv.env['DEMO_USERNAME'] ?? 'kminchelle';
  }

  /// Demo password untuk development
  static String get demoPassword {
    _checkInitialization();
    return dotenv.env['DEMO_PASSWORD'] ?? '0lelplR';
  }

  /// Secondary demo username
  static String get demoUsername2 {
    _checkInitialization();
    return dotenv.env['DEMO_USERNAME_2'] ?? 'emilys';
  }

  /// Secondary demo password
  static String get demoPassword2 {
    _checkInitialization();
    return dotenv.env['DEMO_PASSWORD_2'] ?? 'emilyspass';
  }

  /// Fallback username untuk testing
  static String get fallbackUsername {
    _checkInitialization();
    return dotenv.env['DEMO_USERNAME_3'] ?? 'user';
  }

  /// Fallback password untuk testing
  static String get fallbackPassword {
    _checkInitialization();
    return dotenv.env['DEMO_PASSWORD_3'] ?? 'password';
  }

  /// ===========================================
  /// FEATURE FLAGS
  /// ===========================================

  /// Enable wishlist feature
  ///
  /// 💡 KELEBIHAN: Control feature availability tanpa code deployment
  /// 📝 CONTOH PENGGUNAAN:
  /// ```dart
  /// if (EnvironmentService.enableWishlist) {
  ///   return WishlistButton();
  /// } else {
  ///   return SizedBox.shrink();
  /// }
  /// ```
  static bool get enableWishlist {
    _checkInitialization();
    return dotenv.env['ENABLE_WISHLIST']?.toLowerCase() == 'true';
  }

  /// Enable cart feature
  static bool get enableCart {
    _checkInitialization();
    return dotenv.env['ENABLE_CART']?.toLowerCase() == 'true';
  }

  /// Enable user profile feature
  static bool get enableUserProfile {
    _checkInitialization();
    return dotenv.env['ENABLE_USER_PROFILE']?.toLowerCase() == 'true';
  }

  /// Enable product reviews feature
  static bool get enableProductReviews {
    _checkInitialization();
    return dotenv.env['ENABLE_PRODUCT_REVIEWS']?.toLowerCase() == 'true';
  }

  /// ===========================================
  /// UI CONFIGURATION
  /// ===========================================

  /// Enable animations
  static bool get enableAnimations {
    _checkInitialization();
    return dotenv.env['ENABLE_ANIMATIONS']?.toLowerCase() == 'true';
  }

  /// Animation duration in milliseconds
  static int get animationDurationMs {
    _checkInitialization();
    return int.tryParse(dotenv.env['ANIMATION_DURATION_MS'] ?? '') ?? 300;
  }

  /// Enable grid loading placeholders
  static bool get enableGridLoadingPlaceholders {
    _checkInitialization();
    return dotenv.env['GRID_LOADING_PLACEHOLDERS']?.toLowerCase() == 'true';
  }

  /// ===========================================
  /// SECURITY SETTINGS
  /// ===========================================

  /// Session timeout in minutes
  static int get sessionTimeoutMinutes {
    _checkInitialization();
    return int.tryParse(dotenv.env['SESSION_TIMEOUT_MINUTES'] ?? '') ?? 60;
  }

  /// Enable token refresh
  static bool get enableTokenRefresh {
    _checkInitialization();
    return dotenv.env['ENABLE_TOKEN_REFRESH']?.toLowerCase() == 'true';
  }

  /// Require biometric authentication
  static bool get requireBiometric {
    _checkInitialization();
    return dotenv.env['REQUIRE_BIOMETRIC']?.toLowerCase() == 'true';
  }

  /// ===========================================
  /// CACHE SETTINGS
  /// ===========================================

  /// Enable product cache
  static bool get enableProductCache {
    _checkInitialization();
    return dotenv.env['ENABLE_PRODUCT_CACHE']?.toLowerCase() == 'true';
  }

  /// Product cache duration in minutes
  static int get productCacheDurationMinutes {
    _checkInitialization();
    return int.tryParse(dotenv.env['PRODUCT_CACHE_DURATION_MINUTES'] ?? '') ?? 30;
  }

  /// Enable image cache
  static bool get enableImageCache {
    _checkInitialization();
    return dotenv.env['ENABLE_IMAGE_CACHE']?.toLowerCase() == 'true';
  }

  /// ===========================================
  /// UTILITY METHODS
  /// ===========================================

  /// Check if environment service is initialized
  static void _checkInitialization() {
    if (!_isInitialized) {
      throw Exception(
        'EnvironmentService not initialized! '
        'Call EnvironmentService.initialize() before using environment variables.'
      );
    }
  }

  /// Get all environment variables (for debugging)
  ///
  /// 🚨 WARNING: Hanya gunakan untuk debugging, jangan log sensitive data!
  static Map<String, String> getAllEnvironmentVariables() {
    _checkInitialization();
    return Map.from(dotenv.env);
  }

  /// Check if running in production mode
  static bool get isProduction {
    return currentEnvironment.toLowerCase() == 'production';
  }

  /// Check if running in development mode
  static bool get isDevelopment {
    return currentEnvironment.toLowerCase() == 'development';
  }

  /// Check if running in staging mode
  static bool get isStaging {
    return currentEnvironment.toLowerCase() == 'staging';
  }
}