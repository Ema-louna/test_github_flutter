/**
 * CST2335 Final Project
 * Student: Emanuelle Marchant (041173314)
 * Date: Nov 30, 2025
 *
 * Data Access Object (DAO) for the Car entity.
 * Provides CRUD operations for the local Floor database.
 */

import 'package:floor/floor.dart';
import 'Car.dart';

@dao
abstract class CarDAO {
  /// Returns all cars stored in the database.
  @Query('SELECT * FROM Car')
  Future<List<Car>> getAllCars();

  /// Inserts a new car and returns the generated primary key.
  @insert
  Future<int> insertCar(Car c);

  /// Updates an existing car entry.
  @update
  Future<void> updateCar(Car c);

  /// Deletes a car from the database.
  @delete
  Future<void> deleteCar(Car c);
}
