import 'package:floor/floor.dart';
import 'Car.dart';

@dao
abstract class CarDAO {
  @Query('SELECT * FROM Car')
  Future<List<Car>> getAllCars();

  @insert
  Future<int> insertCar(Car c);

  @update
  Future<void> updateCar(Car c);

  @delete
  Future<void> deleteCar(Car c);
}
