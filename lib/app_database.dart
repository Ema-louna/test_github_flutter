import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'boat_listing.dart';
import 'boat_listing_dao.dart';

part 'app_database.g.dart';

@Database(version: 1, entities: [BoatListing])
abstract class AppDatabase extends FloorDatabase {
  BoatListingDao get boatListingDao;
}

Future<AppDatabase> buildDb() async {
  return await $FloorAppDatabase.databaseBuilder('boat_listings.db').build();
}
