import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../const/locale_constants.dart';

/// Application localization service
///
/// This class handles all internationalization functionality including:
/// - Loading translation files from assets
/// - Managing current locale state
/// - Providing translated strings
/// - Persisting user language preferences
///
/// # Usage:
/// ```dart
/// // In your widget build method
/// final localizations = AppLocalizations.of(context);
/// final title = localizations.translate('product.title');
/// ```
///
/// # Implementation Guide:
/// 1. Add new translation keys to the JSON files in assets/translations/
/// 2. Use dot notation for nested keys (e.g., 'product.title')
/// 3. Call updateLocale() to change language programmatically
/// 4. Localizations are automatically persisted to SharedPreferences

class AppLocalizations {
  final Locale locale;

  // Private constructor - use of() method instead
  AppLocalizations(this.locale);

  // Static instance cache for performance
  static final Map<String, AppLocalizations> _instances = {};

  // Translation cache for each locale
  static final Map<String, Map<String, dynamic>> _translations = {};

  /// Gets the AppLocalizations instance for the current context
  ///
  /// [context] The BuildContext containing the Localizations widget
  /// Returns the AppLocalizations instance for the current locale
  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  /// Loads translations for a specific locale from assets
  ///
  /// [locale] The locale to load translations for
  /// Returns a Map containing all translation keys and values
  static Future<Map<String, dynamic>> loadTranslations(Locale locale) async {
    final languageCode = locale.languageCode;

    // Return cached translations if already loaded
    if (_translations.containsKey(languageCode)) {
      return _translations[languageCode]!;
    }

    try {
      // Load translation file from assets
      final String jsonString = await rootBundle.loadString(
        'assets/translations/$languageCode.json'
      );

      // Parse JSON and cache it
      final Map<String, dynamic> translations = json.decode(jsonString);
      _translations[languageCode] = translations;

      return translations;
    } catch (e) {
      // Fallback to English if translation file not found
      if (languageCode != 'en') {
        return await loadTranslations(const Locale('en'));
      }

      // Return empty map if English file also not found
      debugPrint('Error loading translations for $languageCode: $e');
      return {};
    }
  }

  /// Creates an AppLocalizations delegate for the app
  ///
  /// Returns a LocalizationsDelegate<AppLocalizations> instance
  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// Translates a key to the current locale
  ///
  /// [key] The translation key (supports dot notation for nested keys)
  /// [args] Optional map of arguments for string interpolation
  /// Returns the translated string or the key if not found
  ///
  /// # Examples:
  /// ```dart
  /// // Simple translation
  /// translate('product.title')
  ///
  /// // Nested key
  /// translate('navigation.home')
  ///
  /// // With arguments
  /// translate('product.error', args: {'error': 'Network timeout'})
  /// ```
  String translate(String key, {Map<String, String>? args}) {
    final languageCode = locale.languageCode;
    final translations = _translations[languageCode] ?? {};

    // Handle nested keys with dot notation
    final keys = key.split('.');
    dynamic value = translations;

    for (final k in keys) {
      if (value is Map<String, dynamic> && value.containsKey(k)) {
        value = value[k];
      } else {
        // Key not found, return the key itself
        debugPrint('Translation key not found: $key');
        return key;
      }
    }

    if (value is! String) {
      debugPrint('Translation value is not a string for key: $key');
      return key;
    }

    // Apply string interpolation if arguments provided
    if (args != null && args.isNotEmpty) {
      return _interpolateString(value, args);
    }

    return value;
  }

  /// Performs string interpolation with arguments
  ///
  /// [string] The template string with placeholders
  /// [args] Map of arguments to replace placeholders
  /// Returns the interpolated string
  String _interpolateString(String string, Map<String, String> args) {
    String result = string;

    for (final entry in args.entries) {
      result = result.replaceAll('{${entry.key}}', entry.value);
    }

    return result;
  }

  /// Updates the current locale
  ///
  /// [newLocale] The new locale to switch to
  /// [savePreference] Whether to save the preference to disk (default: true)
  /// This method should be called through the LanguageProvider
  Future<void> updateLocale(Locale newLocale, {bool savePreference = true}) async {
    // Ensure translations are loaded for the new locale
    await loadTranslations(newLocale);

    // Save preference to SharedPreferences if requested
    if (savePreference) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(LocaleConstants.languageStorageKey, newLocale.languageCode);
      } catch (e) {
        debugPrint('Error saving language preference: $e');
      }
    }
  }

  /// Gets the current language code
  String get currentLanguageCode => locale.languageCode;

  /// Gets the current language name in native format
  String get currentLanguageName => LocaleConstants.getNativeLanguageName(locale.languageCode);

  /// Checks if the current locale is RTL (Right-to-Left)
  bool get isRTL => false; // Currently only LTR languages supported

  // Convenience getters for commonly used translations

  /// App name translation
  String get appName => translate('app.name');

  /// Navigation translations
  String get homeTitle => translate('navigation.home');
  String get cartTitle => translate('navigation.cart');
  String get wishlistTitle => translate('navigation.wishlist');
  String get profileTitle => translate('navigation.profile');

  /// Common translations
  String get okText => translate('common.ok');
  String get cancelText => translate('common.cancel');
  String get yesText => translate('common.yes');
  String get noText => translate('common.no');
  String get saveText => translate('common.save');
  String get deleteText => translate('common.delete');
  String get editText => translate('common.edit');
  String get closeText => translate('common.close');
  String get loadingText => translate('common.loading');
  String get errorText => translate('common.error');
  String get successText => translate('common.success');
  String get retryText => translate('common.retry');

  /// Language translations
  String get changeLanguageText => translate('language.changeLanguage');
  String get languageChangedText => translate('language.languageChanged');
  String get languageErrorText => translate('language.languageError');
}

/// Custom LocalizationsDelegate for AppLocalizations
///
/// This delegate handles:
/// - Loading translations when locale changes
/// - Supporting locale resolution
/// - Caching instances for performance
class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return LocaleConstants.isLanguageSupported(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    // Load translations for the locale
    await AppLocalizations.loadTranslations(locale);

    // Create and return instance
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) => false;
}