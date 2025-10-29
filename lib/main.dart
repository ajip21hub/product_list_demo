import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/const/constants.dart';
import 'core/const/locale_constants.dart';
import 'core/dependency_injection.dart';
import 'core/localization/app_localizations.dart';
import 'core/localization/localization_provider.dart';
import 'core/services/environment_service.dart';
import 'presentation/screens/main_navigation.dart';

/// ===========================================
/// 🚀 MAIN ENTRY POINT WITH .ENV INITIALIZATION
/// ===========================================
///
/// 📚 KELEBIHAN MENGGUNAKAN .ENV DI STARTUP:
///
/// ✅ **EARLY INITIALIZATION**: Environment variables loaded sebelum app start
///    - Semua services bisa mengakses environment variables
///    - Tidak ada null reference issues
///    - Safe fallback jika .env tidak ada
///
/// ✅ **CONFIGURATION FIRST**: Configuration di-load sebelum UI
///    - API endpoints, credentials, dan settings siap
///    - UI bisa menyesuaikan dengan environment
///    - Error handling jika configuration invalid
///
/// ✅ **DEVELOPMENT FRIENDLY**: Debug informasi di startup
///    - Print environment yang sedang aktif
///    - Show API URL yang digunakan
///    - Mudah troubleshooting configuration issues
///
/// 🚨 CARA PENGGUNAAN:
/// 1. .env file harus ada di root project
/// 2. EnvironmentService.initialize() dipanggil pertama kali
/// 3. Semua dependency injection di-load setelah environment siap
/// 4. App running dengan configuration yang benar

void main() async {
  // ===========================================
  // 🔧 ENVIRONMENT INITIALIZATION (CRITICAL)
  // ===========================================
  ///
  /// 📝 STEP 1: Load .env configuration
  /// - Base URL, credentials, dan settings di-load
  /// - Safe fallback jika file tidak ada
  /// - Debug info printed (hanya di debug mode)
  ///
  /// 💡 KELEBIHAN: App tidak akan crash jika .env tidak ada
  /// - Automatic fallback ke default values
  /// - Development tetap berjalan
  /// - Clear warning messages untuk developer

  try {
    await EnvironmentService.initialize();
  } catch (e) {
    // Fallback untuk development jika .env loading gagal
    print('⚠️ Environment initialization failed: $e');
    print('📋 Using default configuration for development');
    // Continue with default values untuk development safety
  }

  // Initialize dependency injection
  DependencyInjectionInitializer.initialize();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the language state for locale changes
    final languageState = ref.watch(languageProvider);
    final currentLocale = languageState.currentLocale;

    // ===========================================
    // 🎨 APP CONFIGURATION DENGAN .ENV VALUES
    // ===========================================
    ///
    /// 📚 CONTOH PENGGUNAAN ENVIRONMENT VALUES DI UI:
    ///
    /// 💡 DEBUG MODE: Hide/show debug features
    /// ```dart
    /// if (EnvironmentService.isDebug) {
    ///   return DebugPanel();
    /// }
    /// ```
    ///
    /// 💡 FEATURE FLAGS: Enable/disable features
    /// ```dart
    /// if (EnvironmentService.enableWishlist) {
    ///   return WishlistButton();
    /// }
    /// ```
    ///
    /// 💡 ANIMATIONS: Control per-environment
    /// ```dart
    /// duration: Duration(
    ///   milliseconds: EnvironmentService.animationDurationMs
    /// ),
    /// ```

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: EnvironmentService.isDebug,

      // Localization configuration
      locale: currentLocale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: LocaleConstants.supportedLocales,
      localeResolutionCallback: (locale, supportedLocales) {
        // If the device locale is supported, use it
        if (locale != null) {
          for (final supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale.languageCode) {
              return supportedLocale;
            }
          }
        }
        // Otherwise use the default locale
        return LocaleConstants.defaultLocale;
      },

      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        cardTheme: CardThemeData(
          elevation: UIConstants.cardElevation,
          shape: RoundedRectangleBorder(
            borderRadius: UIConstants.borderRadiusLarge,
          ),
        ),
      ),
      home: const MainNavigation(),
    );
  }
}
