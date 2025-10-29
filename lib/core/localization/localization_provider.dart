import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../const/locale_constants.dart';
import 'app_localizations.dart';

/// Language provider state
///
/// Contains the current locale and loading state for language management.
/// This state is used throughout the application to determine which
/// translations to display and to manage language switching.
class LanguageState {
  final Locale currentLocale;
  final bool isLoading;
  final String? error;

  const LanguageState({
    required this.currentLocale,
    this.isLoading = false,
    this.error,
  });

  /// Creates a copy with updated values
  LanguageState copyWith({
    Locale? currentLocale,
    bool? isLoading,
    String? error,
  }) {
    return LanguageState(
      currentLocale: currentLocale ?? this.currentLocale,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LanguageState &&
        other.currentLocale == currentLocale &&
        other.isLoading == isLoading &&
        other.error == error;
  }

  @override
  int get hashCode => currentLocale.hashCode ^ isLoading.hashCode ^ error.hashCode;

  @override
  String toString() => 'LanguageState(currentLocale: $currentLocale, isLoading: $isLoading, error: $error)';
}

/// Language notifier for managing application language state
///
/// This notifier handles:
/// - Loading saved language preferences from SharedPreferences
/// - Changing the current locale
/// - Persisting language preferences
/// - Managing loading and error states
///
/// # Usage:
/// ```dart
/// final languageNotifier = ref.read(languageProvider.notifier);
/// await languageNotifier.changeLanguage('id');
/// ```
class LanguageNotifier extends StateNotifier<LanguageState> {
  LanguageNotifier() : super(const LanguageState(currentLocale: LocaleConstants.defaultLocale));

  /// Initializes the language provider by loading saved preferences
  ///
  /// This method should be called when the app starts to restore
  /// the user's previous language selection. Falls back to the
  /// system locale or default locale if no preference is saved.
  Future<void> initialize() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguageCode = prefs.getString(LocaleConstants.languageStorageKey);

      Locale initialLocale;

      if (savedLanguageCode != null && LocaleConstants.isLanguageSupported(savedLanguageCode)) {
        // Use saved preference
        initialLocale = LocaleConstants.getLocaleFromLanguageCode(savedLanguageCode);
      } else {
        // Use system locale if supported, otherwise use default
        final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
        if (LocaleConstants.isLanguageSupported(systemLocale.languageCode)) {
          initialLocale = systemLocale;
        } else {
          initialLocale = LocaleConstants.defaultLocale;
        }
      }

      // Load translations for the initial locale
      await AppLocalizations.loadTranslations(initialLocale);

      state = LanguageState(currentLocale: initialLocale);
    } catch (e) {
      state = LanguageState(
        currentLocale: LocaleConstants.defaultLocale,
        error: 'Failed to initialize language: $e',
      );
    }
  }

  /// Changes the current application language
  ///
  /// [languageCode] The language code to switch to (e.g., 'en', 'id')
  /// Returns true if successful, false otherwise
  ///
  /// # Implementation Guide:
  /// 1. Validates the language code is supported
  /// 2. Updates the state with new locale
  /// 3. Persists the preference to SharedPreferences
  /// 4. Loads translations for the new locale
  ///
  /// # Error Handling:
  /// - Shows error message if language code is invalid
  /// - Falls back to current locale if change fails
  /// - Updates state with error information
  Future<bool> changeLanguage(String languageCode) async {
    // Validate language code
    if (!LocaleConstants.isLanguageSupported(languageCode)) {
      state = state.copyWith(error: 'Unsupported language code: $languageCode');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final newLocale = LocaleConstants.getLocaleFromLanguageCode(languageCode);

      // Load translations for the new locale
      await AppLocalizations.loadTranslations(newLocale);

      // Update state
      state = LanguageState(currentLocale: newLocale);

      // Save preference
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(LocaleConstants.languageStorageKey, languageCode);

      return true;
    } catch (e) {
      state = state.copyWith(
        currentLocale: state.currentLocale, // Keep current locale on error
        isLoading: false,
        error: 'Failed to change language: $e',
      );
      return false;
    }
  }

  /// Changes the current application language using Locale object
  ///
  /// [newLocale] The Locale to switch to
  /// Returns true if successful, false otherwise
  Future<bool> changeLocale(Locale newLocale) async {
    return await changeLanguage(newLocale.languageCode);
  }

  /// Resets to the default language
  ///
  /// Clears the saved preference and switches to default locale.
  /// Useful for testing or when user wants to reset to default.
  Future<bool> resetToDefault() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Load translations for default locale
      await AppLocalizations.loadTranslations(LocaleConstants.defaultLocale);

      state = LanguageState(currentLocale: LocaleConstants.defaultLocale);

      // Clear saved preference
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(LocaleConstants.languageStorageKey);

      return true;
    } catch (e) {
      state = state.copyWith(
        currentLocale: state.currentLocale,
        isLoading: false,
        error: 'Failed to reset to default language: $e',
      );
      return false;
    }
  }

  /// Gets the current language code
  String get currentLanguageCode => state.currentLocale.languageCode;

  /// Gets the current language name in native format
  String get currentLanguageName => LocaleConstants.getNativeLanguageName(state.currentLocale.languageCode);

  /// Checks if the current language is the default language
  bool get isDefaultLanguage => state.currentLocale == LocaleConstants.defaultLocale;

  /// Clears any error state
  void clearError() {
    if (state.error != null) {
      state = state.copyWith(error: null);
    }
  }
}

/// Riverpod provider for language management
///
/// This provider provides:
/// - Current language state (locale, loading, error)
/// - Language changing functionality
/// - Integration with SharedPreferences
/// - Automatic initialization
///
/// # Usage:
/// ```dart
/// // Watch language state
/// final languageState = ref.watch(languageProvider);
/// final currentLocale = languageState.currentLocale;
///
/// // Change language
/// final languageNotifier = ref.read(languageProvider.notifier);
/// await languageNotifier.changeLanguage('id');
/// ```
final languageProvider = StateNotifierProvider<LanguageNotifier, LanguageState>((ref) {
  final notifier = LanguageNotifier();

  // Initialize when provider is first created
  WidgetsBinding.instance.addPostFrameCallback((_) {
    notifier.initialize();
  });

  return notifier;
});

/// Provider for current locale
///
/// Convenience provider that only exposes the current locale
/// for use in widgets that only need the locale information.
final currentLocaleProvider = Provider<Locale>((ref) {
  return ref.watch(languageProvider).currentLocale;
});

/// Provider for current language code
///
/// Convenience provider that only exposes the language code
/// for use in API calls, storage operations, etc.
final currentLanguageCodeProvider = Provider<String>((ref) {
  return ref.watch(languageProvider).currentLocale.languageCode;
});

/// Provider for AppLocalizations instance
///
/// Provides the AppLocalizations instance for the current locale.
/// This can be used in widgets that need access to translations
/// outside of the build context.
final appLocalizationsProvider = Provider<AppLocalizations>((ref) {
  final locale = ref.watch(currentLocaleProvider);
  return AppLocalizations(locale);
});