import 'package:floor/floor.dart';
import 'boat_item.dart';

@dao
abstract class BoatItemDao {
  @Query('SELECT * FROM BoatItem ORDER BY id DESC')
  Future<List<BoatItem>> findAll();

  @insert
  Future<int> insertItem(BoatItem item);

  @Query('DELETE FROM BoatItem WHERE id = :id')
  Future<void> deleteById(int id);
}
