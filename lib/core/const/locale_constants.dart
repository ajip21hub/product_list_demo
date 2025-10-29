/// Localization constants and configuration
///
/// This file contains constants for supported locales, language codes,
/// and configuration for the multi-language feature implementation.
///
/// # Usage:
/// ```dart
/// // Get supported locales
/// final locales = LocaleConstants.supportedLocales;
///
/// // Get default locale
/// final defaultLocale = LocaleConstants.defaultLocale;
///
/// // Get language name
/// final languageName = LocaleConstants.getLanguageName('en');
/// ```
///
/// # Implementation Guide:
/// 1. Add new locales to supportedLocales list
/// 2. Update getLanguageName() method for new languages
/// 3. Create corresponding JSON translation file in assets/translations/
/// 4. Update language switcher widget to include new option

import 'package:flutter/material.dart';

class LocaleConstants {
  // Private constructor to prevent instantiation
  LocaleConstants._();

  /// Supported locales by the application
  /// Add new locales here when adding new language support
  static const List<Locale> supportedLocales = [
    Locale('en'), // English
    Locale('id'), // Indonesian
  ];

  /// Default locale when user preference is not set
  static const Locale defaultLocale = Locale('en');

  /// Language codes supported by the application
  static const List<String> supportedLanguageCodes = [
    'en', // English
    'id', // Indonesian
  ];

  /// Storage key for persisting user language preference
  /// Used with SharedPreferences to store user's language choice
  static const String languageStorageKey = 'user_language';

  /// Gets the display name for a language code
  ///
  /// [languageCode] The language code (e.g., 'en', 'id')
  /// Returns the localized language name in the language itself
  ///
  /// # Implementation:
  /// - Add new language mappings when adding new locales
  /// - Use native language names for better UX
  static String getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'id':
        return 'Bahasa Indonesia';
      default:
        return languageCode.toUpperCase();
    }
  }

  /// Gets the native language name (in the language itself)
  ///
  /// [languageCode] The language code (e.g., 'en', 'id')
  /// Returns the language name in its native form
  static String getNativeLanguageName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'id':
        return 'Indonesia';
      default:
        return languageCode.toUpperCase();
    }
  }

  /// Checks if a language code is supported
  ///
  /// [languageCode] The language code to check
  /// Returns true if the language is supported, false otherwise
  static bool isLanguageSupported(String languageCode) {
    return supportedLanguageCodes.contains(languageCode);
  }

  /// Gets the locale from language code
  ///
  /// [languageCode] The language code (e.g., 'en', 'id')
  /// Returns the corresponding Locale object or default locale if not found
  static Locale getLocaleFromLanguageCode(String languageCode) {
    try {
      return supportedLocales.firstWhere(
        (locale) => locale.languageCode == languageCode,
        orElse: () => defaultLocale,
      );
    } catch (e) {
      return defaultLocale;
    }
  }

  /// Gets the language code from locale
  ///
  /// [locale] The Locale object
  /// Returns the language code string
  static String getLanguageCodeFromLocale(Locale locale) {
    return locale.languageCode;
  }

  /// Gets the country code for a language (for flag display)
  ///
  /// [languageCode] The language code (e.g., 'en', 'id')
  /// Returns the country code for flag display
  static String getCountryCode(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'US'; // United States flag for English
      case 'id':
        return 'ID'; // Indonesia flag for Indonesian
      default:
        return '';
    }
  }

  /// Gets all available language options for the language switcher
  ///
  /// Returns a map of language codes to their display names
  static Map<String, String> getLanguageOptions() {
    return {
      for (String code in supportedLanguageCodes)
        code: getNativeLanguageName(code),
    };
  }

  /// Validates and returns a safe locale
  ///
  /// [languageCode] The language code to validate
  /// Returns the validated locale or default locale if invalid
  static Locale getSafeLocale(String? languageCode) {
    if (languageCode == null || !isLanguageSupported(languageCode)) {
      return defaultLocale;
    }
    return getLocaleFromLanguageCode(languageCode);
  }
}