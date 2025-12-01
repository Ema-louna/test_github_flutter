import 'package:floor/floor.dart';
/// Purchase entity class for database storage
///
/// Represents a purchase  information including
/// customerId, vehicleId (boat or car), price, dateofOffer, status(accepted or
/// rejected).
@entity
class Purchase {
  /// Unique identifier for the purchase
  @primaryKey
  final int? id;

  /// CustomerId for purchase
  final String customerID;
  /// vehicle's ID
  final String vehicleId;
  /// Price of purchase
  final String price;
  /// Purchase's date of offer  in YYYY-MM-DD format
  final String dateOfOffer;
  /// Purchase's status
  final String status;

  /// Static counter for generating unique IDs
  static int ID = 1;

  /// Creates a new Package instance
  ///
  /// [id] Unique identifier (auto-generated if null)
  /// [customerID] Customer's id for purchase
  /// [vehicleId] vehicle's id for purchase
  /// [price] Purchase's price
  /// [dateOfOffer] Date of offer
  /// [status] status of purchase
    Purchase(
      this.id,
      this.customerID,
      this.vehicleId,
      this.price,
      this.dateOfOffer,
      this.status,
      ) {
    // Update ID counter if loaded ID is higher
    if (id != null && id! >= ID) {
      ID = id! + 1;
    }
  }
}