import 'package:floor/floor.dart';

@Entity(tableName: 'BoatItem')
class BoatItem {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  final String name;

  const BoatItem({this.id, required this.name});
}
