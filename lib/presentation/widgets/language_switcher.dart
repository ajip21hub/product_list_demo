import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/const/locale_constants.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/localization/localization_provider.dart';

/// Language switcher widget for changing application language
///
/// This widget provides:
/// - Dropdown menu for language selection
/// - Visual feedback during language switching
/// - Integration with language provider
/// - Support for both logged-in and guest users
///
/// # Usage:
/// ```dart
/// // Simple usage
/// LanguageSwitcher()
///
/// // With custom styling
/// LanguageSwitcher(
///   showFlag: true,
///   isDense: true,
///   style: TextStyle(fontSize: 14),
/// )
///
/// // As a menu button
/// LanguageSwitcher(
///   type: LanguageSwitcherType.menuButton,
///   icon: Icon(Icons.language),
/// )
/// ```
///
/// # Implementation Guide:
/// 1. Place in app bar, settings screen, or profile section
/// 2. Language changes are persisted for both logged-in and guest users
/// 3. Widget automatically updates when language changes
/// 4. Shows loading state during language switching
///
/// # Error Handling:
/// - Shows error message if language change fails
/// - Falls back to current language on error
/// - Displays loading indicator during switch

enum LanguageSwitcherType {
  dropdown,     // Standard dropdown menu
  menuButton,   // Button with dropdown menu
  segmented,    // Segmented control style
  toggle,       // Simple toggle button
}

class LanguageSwitcher extends ConsumerWidget {
  final LanguageSwitcherType type;
  final bool showFlag;
  final bool isDense;
  final TextStyle? style;
  final Widget? icon;
  final EdgeInsetsGeometry? padding;
  final String? hint;
  final double? borderRadius;

  const LanguageSwitcher({
    super.key,
    this.type = LanguageSwitcherType.dropdown,
    this.showFlag = true,
    this.isDense = false,
    this.style,
    this.icon,
    this.padding,
    this.hint,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageState = ref.watch(languageProvider);
    final languageNotifier = ref.read(languageProvider.notifier);
    final localizations = AppLocalizations.of(context)!;

    final currentLanguageCode = languageState.currentLocale.languageCode;

    switch (type) {
      case LanguageSwitcherType.dropdown:
        return _buildDropdown(context, ref, currentLanguageCode, languageNotifier, localizations);
      case LanguageSwitcherType.menuButton:
        return _buildMenuButton(context, ref, currentLanguageCode, languageNotifier, localizations);
      case LanguageSwitcherType.segmented:
        return _buildSegmented(context, ref, currentLanguageCode, languageNotifier, localizations);
      case LanguageSwitcherType.toggle:
        return _buildToggle(context, ref, currentLanguageCode, languageNotifier, localizations);
    }
  }

  /// Builds dropdown style language switcher
  Widget _buildDropdown(
    BuildContext context,
    WidgetRef ref,
    String currentLanguageCode,
    LanguageNotifier languageNotifier,
    AppLocalizations localizations,
  ) {
    final languageState = ref.watch(languageProvider);

    return DropdownButton<String>(
      value: currentLanguageCode,
      hint: Text(hint ?? localizations.translate('language.changeLanguage')),
      isDense: isDense,
      style: style ?? Theme.of(context).textTheme.bodyMedium,
      underline: Container(),
      borderRadius: BorderRadius.circular(borderRadius ?? 8),
      items: LocaleConstants.getLanguageOptions().entries.map((entry) {
        final languageCode = entry.key;
        final languageName = entry.value;
        final isSelected = languageCode == currentLanguageCode;

        return DropdownMenuItem<String>(
          value: languageCode,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showFlag) ...[
                _buildFlag(languageCode),
                const SizedBox(width: 8),
              ],
              Text(
                languageName,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: languageState.isLoading ? null : (String? newLanguageCode) async {
        if (newLanguageCode != null && newLanguageCode != currentLanguageCode) {
          await _handleLanguageChange(
            context,
            languageNotifier,
            newLanguageCode,
            localizations,
          );
        }
      },
    );
  }

  /// Builds menu button style language switcher
  Widget _buildMenuButton(
    BuildContext context,
    WidgetRef ref,
    String currentLanguageCode,
    LanguageNotifier languageNotifier,
    AppLocalizations localizations,
  ) {
    final languageState = ref.watch(languageProvider);

    return PopupMenuButton<String>(
      icon: icon ?? const Icon(Icons.language),
      tooltip: localizations.translate('language.changeLanguage'),
      position: PopupMenuPosition.under,
      itemBuilder: (context) => LocaleConstants.getLanguageOptions().entries.map((entry) {
        final languageCode = entry.key;
        final languageName = entry.value;
        final isSelected = languageCode == currentLanguageCode;

        return PopupMenuItem<String>(
          value: languageCode,
          enabled: !languageState.isLoading,
          child: Row(
            children: [
              if (showFlag) ...[
                _buildFlag(languageCode),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  languageName,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(Icons.check, color: Colors.blue),
            ],
          ),
        );
      }).toList(),
      onSelected: (String? newLanguageCode) async {
        if (newLanguageCode != null && newLanguageCode != currentLanguageCode) {
          await _handleLanguageChange(
            context,
            languageNotifier,
            newLanguageCode,
            localizations,
          );
        }
      },
    );
  }

  /// Builds segmented control style language switcher
  Widget _buildSegmented(
    BuildContext context,
    WidgetRef ref,
    String currentLanguageCode,
    LanguageNotifier languageNotifier,
    AppLocalizations localizations,
  ) {
    final languageState = ref.watch(languageProvider);

    return SegmentedButton<String>(
      segments: LocaleConstants.getLanguageOptions().entries.map((entry) {
        final languageCode = entry.key;
        final languageName = entry.value;

        return ButtonSegment<String>(
          value: languageCode,
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showFlag) ...[
                _buildFlag(languageCode, size: 16),
                const SizedBox(width: 6),
              ],
              Text(languageName),
            ],
          ),
        );
      }).toList(),
      selected: {currentLanguageCode},
      onSelectionChanged: languageState.isLoading
          ? null
          : (Set<String> newSelection) async {
              final newLanguageCode = newSelection.first;
              if (newLanguageCode != currentLanguageCode) {
                await _handleLanguageChange(
                  context,
                  languageNotifier,
                  newLanguageCode,
                  localizations,
                );
              }
            },
    );
  }

  /// Builds toggle button style language switcher
  Widget _buildToggle(
    BuildContext context,
    WidgetRef ref,
    String currentLanguageCode,
    LanguageNotifier languageNotifier,
    AppLocalizations localizations,
  ) {
    final languageState = ref.watch(languageProvider);
    final isEnglish = currentLanguageCode == 'en';

    return IconButton.filled(
      onPressed: languageState.isLoading ? null : () async {
        final newLanguageCode = isEnglish ? 'id' : 'en';
        await _handleLanguageChange(
          context,
          languageNotifier,
          newLanguageCode,
          localizations,
        );
      },
      icon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showFlag) ...[
            _buildFlag(currentLanguageCode),
            const SizedBox(width: 6),
          ],
          Text(
            isEnglish ? 'EN' : 'ID',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.swap_horiz, size: 16),
        ],
      ),
    );
  }

  /// Builds country flag emoji for language
  Widget _buildFlag(String languageCode, {double size = 20}) {
    String flagEmoji;
    switch (languageCode) {
      case 'en':
        flagEmoji = '🇺🇸'; // US flag for English
        break;
      case 'id':
        flagEmoji = '🇮🇩'; // Indonesia flag
        break;
      default:
        flagEmoji = '🌐'; // Globe emoji for unknown languages
    }

    return Text(
      flagEmoji,
      style: TextStyle(fontSize: size),
    );
  }

  /// Handles language change with proper error handling and user feedback
  Future<void> _handleLanguageChange(
    BuildContext context,
    LanguageNotifier languageNotifier,
    String newLanguageCode,
    AppLocalizations localizations,
  ) async {
    // Show loading indicator
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    // Change language
    final success = await languageNotifier.changeLanguage(newLanguageCode);

    if (success) {
      // Show success message
      final languageName = LocaleConstants.getNativeLanguageName(newLanguageCode);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            localizations.translate('language.languageChanged', args: {
              'language': languageName,
            }),
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.translate('language.languageError')),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: localizations.translate('common.retry'),
            textColor: Colors.white,
            onPressed: () => _handleLanguageChange(
              context,
              languageNotifier,
              newLanguageCode,
              localizations,
            ),
          ),
        ),
      );
    }
  }
}

/// Simple language toggle button for quick switching
///
/// A minimal version of the language switcher that just toggles
/// between English and Indonesian with a single tap.
class LanguageToggle extends ConsumerWidget {
  final bool showText;
  final Color? color;
  final double? size;

  const LanguageToggle({
    super.key,
    this.showText = true,
    this.color,
    this.size,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageState = ref.watch(languageProvider);
    final languageNotifier = ref.read(languageProvider.notifier);
    final localizations = AppLocalizations.of(context)!;

    final isEnglish = languageState.currentLocale.languageCode == 'en';
    final displayText = isEnglish ? 'EN' : 'ID';

    return IconButton(
      onPressed: languageState.isLoading ? null : () async {
        final newLanguageCode = isEnglish ? 'id' : 'en';
        await languageNotifier.changeLanguage(newLanguageCode);

        // Show brief feedback
        if (context.mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                localizations.translate('language.languageChanged', args: {
                  'language': LocaleConstants.getNativeLanguageName(newLanguageCode),
                }),
              ),
              duration: const Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      icon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showText) ...[
            Text(
              displayText,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: size,
              ),
            ),
            const SizedBox(width: 4),
          ],
          Icon(
            Icons.swap_horiz,
            color: color,
            size: size,
          ),
        ],
      ),
      tooltip: localizations.translate('language.changeLanguage'),
    );
  }
}