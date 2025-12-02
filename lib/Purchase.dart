import 'package:floor/floor.dart';
import 'dart:convert';

/// Purchase entity class for database storage
/// Represents a purchase including customerId, vehicleId, price, dateOfOffer, status (accepted/rejected).
@entity
class Purchase {
  /// Unique identifier for the purchase
  @primaryKey
  final int? id;

  /// Customer ID for purchase
  final String customerID;

  /// Vehicle's ID
  final String vehicleId;

  /// Price of purchase
  final String price;

  /// Date of offer in YYYY-MM-DD format
  final String dateOfOffer;

  /// Status of purchase
  final String status;

  /// Static counter for generating unique IDs
  static int ID = 1;

  /// Constructor
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

  /// Convert Purchase object to JSON Map
  Map<String, dynamic> toJson() => {
    'id': id,
    'customerID': customerID,
    'vehicleId': vehicleId,
    'price': price,
    'dateOfOffer': dateOfOffer,
    'status': status,
  };

  /// Create Purchase object from JSON Map
  factory Purchase.fromJson(Map<String, dynamic> json) => Purchase(
    json['id'],
    json['customerID'],
    json['vehicleId'],
    json['price'],
    json['dateOfOffer'],
    json['status'],
  );

  /// Optional: Encode Purchase to JSON string
  String toJsonString() => jsonEncode(toJson());

  /// Optional: Decode JSON string to Purchase
  factory Purchase.fromJsonString(String jsonString) =>
      Purchase.fromJson(jsonDecode(jsonString));
}
