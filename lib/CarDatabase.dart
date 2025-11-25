import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'Car.dart';
import 'CarDAO.dart';

part 'CarDatabase.g.dart';



@Database(version: 1, entities: [Car])
abstract class CarDatabase extends FloorDatabase {
  CarDAO get carDao;
}
