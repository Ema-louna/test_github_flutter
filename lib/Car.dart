import 'package:floor/floor.dart';

@entity
class Car {
  static int ID = 1;

  Car(
      this.id,
      this.name,
      this.model,
      this.year,
      this.color,
      this.description
      ) {
    if (this.id > ID) {
      ID = this.id + 1;
    }
  }

  @primaryKey
  final int id;

  String name;
  String model;
  String year;
  String color;
  String description;
}
