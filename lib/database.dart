import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'customer.dart';
import 'customer_dao.dart';

part 'database.g.dart';

/// Main application database
///
/// Floor database containing the Customer entity.
/// Provides access to CustomerDao for database operations.
@Database(version: 1, entities: [Customer])
abstract class AppDatabase extends FloorDatabase {
  /// Returns the CustomerDao for database operations
  CustomerDao get customerDao;
}