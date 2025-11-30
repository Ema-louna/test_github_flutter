import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Handles application localization and translations
class AppLocalizations {
  final Locale locale;
  Map<String, String>? _localizedStrings;

  AppLocalizations(this.locale);

  /// Access localization from context
  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  /// The localization delegate
  static const LocalizationsDelegate<AppLocalizations> delegate =
  _AppLocalizationsDelegate();

  /// Load JSON file based on locale
  Future<bool> load() async {
    final jsonString = await rootBundle
        .loadString('assets/translations/${locale.languageCode}.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonString);

    _localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });

    return true;
  }

  /// Safe translator — ALWAYS returns a string
  String translate(String key) {
    if (_localizedStrings == null) return key; // Not loaded yet
    return _localizedStrings![key] ?? key;     // Missing key fallback
  }
}

/// Localization delegate
class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'fr'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
