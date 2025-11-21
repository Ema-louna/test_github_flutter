import 'package:floor/floor.dart';

@Entity(tableName: 'BoatListing')
class BoatListing {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  final int yearBuilt;        // example: 2005
  final double lengthMeters;  // example: 7.5 (meters)
  final String powerType;     // "Sail" or "Motor"
  final double price;         // in your currency
  final String address;       // location

  const BoatListing({
    this.id,
    required this.yearBuilt,
    required this.lengthMeters,
    required this.powerType,
    required this.price,
    required this.address,
  });

  BoatListing copyWith({
    int? id,
    int? yearBuilt,
    double? lengthMeters,
    String? powerType,
    double? price,
    String? address,
  }) {
    return BoatListing(
      id: id ?? this.id,
      yearBuilt: yearBuilt ?? this.yearBuilt,
      lengthMeters: lengthMeters ?? this.lengthMeters,
      powerType: powerType ?? this.powerType,
      price: price ?? this.price,
      address: address ?? this.address,
    );
  }
}
