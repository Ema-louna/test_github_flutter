import 'package:floor/floor.dart';
import 'boat_listing.dart';

@dao
abstract class BoatListingDao {
  @Query('SELECT * FROM BoatListing ORDER BY yearBuilt DESC, id DESC')
  Future<List<BoatListing>> findAll();

  @Query('SELECT * FROM BoatListing WHERE id = :id')
  Future<BoatListing?> findById(int id);

  @insert
  Future<int> insertListing(BoatListing listing);

  @update
  Future<int> updateListing(BoatListing listing);

  @delete
  Future<int> deleteListing(BoatListing listing);
}
