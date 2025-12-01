import 'package:floor/floor.dart';
import 'Purchase.dart';

/// Data Access Object for purchase operations
///
/// Provides methods to interact with the purchase table
/// in the database including CRUD operations.
@dao
abstract class PurchaseDao {
  /// Retrieves all purchases  from the database
  ///
  /// Returns a Future containing a list of all purchase objects
  @Query('SELECT * FROM purchase')
  Future<List<Purchase>> findAllPurchase();

  /// Inserts a new purchase into the database
  ///
  /// [purchase] The purchase item  object to insert
  @insert
  Future<void> insertPurchase(Purchase purchase);

  /// Deletes a purchase from the database
  ///
  /// [purchase] The purchase item  object to delete
  @delete
  Future<void> deletePurchase(Purchase purchase);

  /// Updates an existing purchase in the database
  ///
  /// [purchase] The customer object with updated information
  /// Uses replace strategy for conflicts
  @Update(onConflict: OnConflictStrategy.replace)
  Future<void> updatePurchase(Purchase purchase);
}