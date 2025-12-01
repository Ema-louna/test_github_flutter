import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'Purchase.dart';
import 'PurchaseDao.dart';

part 'PurchaseDatabase.g.dart';

/// Main application database
///
/// Floor database containing the Customer entity.
/// Provides access to CustomerDao for database operations.
@Database(version: 1, entities: [Purchase])
abstract class AppDatabase extends FloorDatabase {
  /// Returns the CustomerDao for database operations
  PurchaseDao get purchaseDao;
}