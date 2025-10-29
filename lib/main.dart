import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/const/constants.dart';
import 'core/const/locale_constants.dart';
import 'core/dependency_injection.dart';
import 'core/localization/app_localizations.dart';
import 'core/localization/localization_provider.dart';
import 'presentation/screens/main_navigation.dart';

void main() {
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

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,

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
