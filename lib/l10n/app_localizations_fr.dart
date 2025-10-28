// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Voitures à vendre';

  @override
  String get addCar => 'Ajouter une voiture';

  @override
  String get enterCarName => 'Entrez le nom/modèle de la voiture';

  @override
  String get instructionsTitle => 'Instructions';

  @override
  String get instructionsText => 'Pour ajouter une voiture, tapez le nom et appuyez sur \"Ajouter une voiture\". Sélectionnez une voiture pour la voir, la modifier ou la supprimer. Sur un grand écran, les détails apparaissent à côté de la liste.';

  @override
  String get ok => 'Ok';
}
