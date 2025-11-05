import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'boat_item.dart';
import 'boat_item_dao.dart';

part 'app_database.g.dart';

@Database(version: 1, entities: [BoatItem])
abstract class AppDatabase extends FloorDatabase {
  BoatItemDao get boatItemDao;
}

Future<AppDatabase> buildDb() async {
  return await $FloorAppDatabase.databaseBuilder('boat_items.db').build();
}
