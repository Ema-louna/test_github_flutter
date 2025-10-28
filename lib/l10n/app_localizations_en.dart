// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Cars for Sale';

  @override
  String get addCar => 'Add Car';

  @override
  String get enterCarName => 'Enter car name/model';

  @override
  String get instructionsTitle => 'Instructions';

  @override
  String get instructionsText => 'To add a car, type the name and press \"Add Car\". Select a car to view, update, or delete it. On a large screen, details appear beside the list.';

  @override
  String get ok => 'Ok';
}
