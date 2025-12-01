// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'PurchaseDatabase.dart';

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

  PurchaseDao? _purchaseDaoInstance;

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
            'CREATE TABLE IF NOT EXISTS `Purchase` (`id` INTEGER, `customerID` TEXT NOT NULL, `vehicleId` TEXT NOT NULL, `price` TEXT NOT NULL, `dateOfOffer` TEXT NOT NULL, `status` TEXT NOT NULL, PRIMARY KEY (`id`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  PurchaseDao get purchaseDao {
    return _purchaseDaoInstance ??= _$PurchaseDao(database, changeListener);
  }
}

class _$PurchaseDao extends PurchaseDao {
  _$PurchaseDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _purchaseInsertionAdapter = InsertionAdapter(
            database,
            'Purchase',
            (Purchase item) => <String, Object?>{
                  'id': item.id,
                  'customerID': item.customerID,
                  'vehicleId': item.vehicleId,
                  'price': item.price,
                  'dateOfOffer': item.dateOfOffer,
                  'status': item.status
                }),
        _purchaseUpdateAdapter = UpdateAdapter(
            database,
            'Purchase',
            ['id'],
            (Purchase item) => <String, Object?>{
                  'id': item.id,
                  'customerID': item.customerID,
                  'vehicleId': item.vehicleId,
                  'price': item.price,
                  'dateOfOffer': item.dateOfOffer,
                  'status': item.status
                }),
        _purchaseDeletionAdapter = DeletionAdapter(
            database,
            'Purchase',
            ['id'],
            (Purchase item) => <String, Object?>{
                  'id': item.id,
                  'customerID': item.customerID,
                  'vehicleId': item.vehicleId,
                  'price': item.price,
                  'dateOfOffer': item.dateOfOffer,
                  'status': item.status
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Purchase> _purchaseInsertionAdapter;

  final UpdateAdapter<Purchase> _purchaseUpdateAdapter;

  final DeletionAdapter<Purchase> _purchaseDeletionAdapter;

  @override
  Future<List<Purchase>> findAllPurchase() async {
    return _queryAdapter.queryList('SELECT * FROM purchase',
        mapper: (Map<String, Object?> row) => Purchase(
            row['id'] as int?,
            row['customerID'] as String,
            row['vehicleId'] as String,
            row['price'] as String,
            row['dateOfOffer'] as String,
            row['status'] as String));
  }

  @override
  Future<void> insertPurchase(Purchase purchase) async {
    await _purchaseInsertionAdapter.insert(purchase, OnConflictStrategy.abort);
  }

  @override
  Future<void> updatePurchase(Purchase purchase) async {
    await _purchaseUpdateAdapter.update(purchase, OnConflictStrategy.replace);
  }

  @override
  Future<void> deletePurchase(Purchase purchase) async {
    await _purchaseDeletionAdapter.delete(purchase);
  }
}
