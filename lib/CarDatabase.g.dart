// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'CarDatabase.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $CarDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $CarDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $CarDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<CarDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorCarDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $CarDatabaseBuilderContract databaseBuilder(String name) =>
      _$CarDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $CarDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$CarDatabaseBuilder(null);
}

class _$CarDatabaseBuilder implements $CarDatabaseBuilderContract {
  _$CarDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $CarDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $CarDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<CarDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$CarDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$CarDatabase extends CarDatabase {
  _$CarDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  CarDAO? _carDaoInstance;

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
            'CREATE TABLE IF NOT EXISTS `Car` (`id` INTEGER NOT NULL, `name` TEXT NOT NULL, `model` TEXT NOT NULL, `year` TEXT NOT NULL, `color` TEXT NOT NULL, `description` TEXT NOT NULL, PRIMARY KEY (`id`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  CarDAO get carDao {
    return _carDaoInstance ??= _$CarDAO(database, changeListener);
  }
}

class _$CarDAO extends CarDAO {
  _$CarDAO(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _carInsertionAdapter = InsertionAdapter(
            database,
            'Car',
            (Car item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'model': item.model,
                  'year': item.year,
                  'color': item.color,
                  'description': item.description
                }),
        _carUpdateAdapter = UpdateAdapter(
            database,
            'Car',
            ['id'],
            (Car item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'model': item.model,
                  'year': item.year,
                  'color': item.color,
                  'description': item.description
                }),
        _carDeletionAdapter = DeletionAdapter(
            database,
            'Car',
            ['id'],
            (Car item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'model': item.model,
                  'year': item.year,
                  'color': item.color,
                  'description': item.description
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Car> _carInsertionAdapter;

  final UpdateAdapter<Car> _carUpdateAdapter;

  final DeletionAdapter<Car> _carDeletionAdapter;

  @override
  Future<List<Car>> getAllCars() async {
    return _queryAdapter.queryList('SELECT * FROM Car',
        mapper: (Map<String, Object?> row) => Car(
            row['id'] as int,
            row['name'] as String,
            row['model'] as String,
            row['year'] as String,
            row['color'] as String,
            row['description'] as String));
  }

  @override
  Future<int> insertCar(Car c) {
    return _carInsertionAdapter.insertAndReturnId(c, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateCar(Car c) async {
    await _carUpdateAdapter.update(c, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteCar(Car c) async {
    await _carDeletionAdapter.delete(c);
  }
}
