import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Handles application localization and translations
///
/// Loads translation strings from JSON files and provides
/// access to localized strings throughout the app.
class AppLocalizations {
  /// The current locale
  final Locale locale;

  /// Map of translation keys to localized strings
  Map<String, String>? _localizedStrings;

  /// Creates an AppLocalizations instance
  ///
  /// [locale] The locale to use for translations
  AppLocalizations(this.locale);

  /// Returns the AppLocalizations instance from context
  ///
  /// [context] Build context
  /// Returns the AppLocalizations instance or null if not found
  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  /// Localization delegate for AppLocalizations
  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// Loads translation strings from JSON file
  ///
  /// Loads the appropriate JSON file based on locale
  /// and parses it into the localizedStrings map.
  /// Returns true if successful.
  Future<bool> load() async {
    String jsonString = await rootBundle.loadString('assets/translations/${locale.languageCode}.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);

    _localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });

    return true;
  }

  /// Translates a key to localized string
  ///
  /// [key] The translation key
  /// Returns the localized string or null if not found
  String? translate(String key) {
    return _localizedStrings?[key];
  }
}

/// Delegate for AppLocalizations
///
/// Handles loading and checking support for locales
class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  /// Checks if the locale is supported
  ///
  /// [locale] The locale to check
  /// Returns true if English or French
  @override
  bool isSupported(Locale locale) {
    return ['en', 'fr'].contains(locale.languageCode);
  }

  /// Loads the AppLocalizations for the given locale
  ///
  /// [locale] The locale to load
  /// Returns a Future with the loaded AppLocalizations
  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  /// Whether the delegate should reload
  ///
  /// [old] The old delegate
  /// Returns false as translations don't change
  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}