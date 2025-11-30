/**
 * CST2335 Final Project
 * Student: Emanuelle Marchant (041173314)
 * Date: Nov 30, 2025
 *
 * Represents a car entity stored in the local database.
 * Fields include year, model, color, and description.
 */

import 'package:floor/floor.dart';

@entity
class Car {
  /// Static ID counter used to generate unique primary keys.
  static int ID = 1;

  /**
   * Creates a Car object with basic information.
   * Automatically adjusts the global ID counter.
   */
  Car(
      this.id,
      this.name,
      this.model,
      this.year,
      this.color,
      this.description,
      ) {
    if (this.id > ID) {
      ID = this.id + 1;
    }
  }

  /// Primary key for the car record.
  @primaryKey
  final int id;

  /// Car make or brand name (e.g., Toyota).
  String name;

  /// Car model name (e.g., Corolla).
  String model;

  /// Year of manufacture.
  String year;

  /// Exterior color.
  String color;

  /// Additional optional details about the car.
  String description;
}
