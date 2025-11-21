// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $AppDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $AppDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<AppDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder implements $AppDatabaseBuilderContract {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $AppDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  BoatListingDao? _boatListingDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `BoatListing` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `yearBuilt` INTEGER NOT NULL, `lengthMeters` REAL NOT NULL, `powerType` TEXT NOT NULL, `price` REAL NOT NULL, `address` TEXT NOT NULL)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  BoatListingDao get boatListingDao {
    return _boatListingDaoInstance ??=
        _$BoatListingDao(database, changeListener);
  }
}

class _$BoatListingDao extends BoatListingDao {
  _$BoatListingDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _boatListingInsertionAdapter = InsertionAdapter(
            database,
            'BoatListing',
            (BoatListing item) => <String, Object?>{
                  'id': item.id,
                  'yearBuilt': item.yearBuilt,
                  'lengthMeters': item.lengthMeters,
                  'powerType': item.powerType,
                  'price': item.price,
                  'address': item.address
                }),
        _boatListingUpdateAdapter = UpdateAdapter(
            database,
            'BoatListing',
            ['id'],
            (BoatListing item) => <String, Object?>{
                  'id': item.id,
                  'yearBuilt': item.yearBuilt,
                  'lengthMeters': item.lengthMeters,
                  'powerType': item.powerType,
                  'price': item.price,
                  'address': item.address
                }),
        _boatListingDeletionAdapter = DeletionAdapter(
            database,
            'BoatListing',
            ['id'],
            (BoatListing item) => <String, Object?>{
                  'id': item.id,
                  'yearBuilt': item.yearBuilt,
                  'lengthMeters': item.lengthMeters,
                  'powerType': item.powerType,
                  'price': item.price,
                  'address': item.address
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<BoatListing> _boatListingInsertionAdapter;

  final UpdateAdapter<BoatListing> _boatListingUpdateAdapter;

  final DeletionAdapter<BoatListing> _boatListingDeletionAdapter;

  @override
  Future<List<BoatListing>> findAll() async {
    return _queryAdapter.queryList(
        'SELECT * FROM BoatListing ORDER BY yearBuilt DESC, id DESC',
        mapper: (Map<String, Object?> row) => BoatListing(
            id: row['id'] as int?,
            yearBuilt: row['yearBuilt'] as int,
            lengthMeters: row['lengthMeters'] as double,
            powerType: row['powerType'] as String,
            price: row['price'] as double,
            address: row['address'] as String));
  }

  @override
  Future<BoatListing?> findById(int id) async {
    return _queryAdapter.query('SELECT * FROM BoatListing WHERE id = ?1',
        mapper: (Map<String, Object?> row) => BoatListing(
            id: row['id'] as int?,
            yearBuilt: row['yearBuilt'] as int,
            lengthMeters: row['lengthMeters'] as double,
            powerType: row['powerType'] as String,
            price: row['price'] as double,
            address: row['address'] as String),
        arguments: [id]);
  }

  @override
  Future<int> insertListing(BoatListing listing) {
    return _boatListingInsertionAdapter.insertAndReturnId(
        listing, OnConflictStrategy.abort);
  }

  @override
  Future<int> updateListing(BoatListing listing) {
    return _boatListingUpdateAdapter.updateAndReturnChangedRows(
        listing, OnConflictStrategy.abort);
  }

  @override
  Future<int> deleteListing(BoatListing listing) {
    return _boatListingDeletionAdapter.deleteAndReturnChangedRows(listing);
  }
}
