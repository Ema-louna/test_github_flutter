/**
 * CST2335 Final Project
 * Student: Emanuelle Marchant (041173314)
 * Date: Nov 30, 2025
 *
 * Floor database configuration for storing Car objects.
 * Provides access to the CarDAO for CRUD operations.
 */

import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'Car.dart';
import 'CarDAO.dart';

part 'CarDatabase.g.dart';

/// Main Floor database for the Car application.
@Database(version: 1, entities: [Car])
abstract class CarDatabase extends FloorDatabase {
  /// DAO used to read and write Car objects.
  CarDAO get carDao;
}
