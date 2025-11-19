import 'package:floor/floor.dart';
/// Customer entity class for database storage
///
/// Represents a customer with personal information including
/// name, address, date of birth, and driver's license.
@entity
class Customer {
  /// Unique identifier for the customer
  @primaryKey
  final int? id;

  /// Customer's first name
  final String firstName;
  /// Customer's last name
  final String lastName;
  /// Customer's residential address
  final String address;
  /// Customer's date of birth in YYYY-MM-DD format
  final String dateOfBirth;
  /// Customer's driver's license number
  final String driverLicense;

  /// Static counter for generating unique IDs
  static int ID = 1;

  /// Creates a new Customer instance
  ///
  /// [id] Unique identifier (auto-generated if null)
  /// [firstName] Customer's first name
  /// [lastName] Customer's last name
  /// [address] Customer's address
  /// [dateOfBirth] Date of birth
  /// [driverLicense] Driver's license number
  Customer(
      this.id,
      this.firstName,
      this.lastName,
      this.address,
      this.dateOfBirth,
      this.driverLicense,
      ) {
    // Update ID counter if loaded ID is higher
    if (id != null && id! >= ID) {
      ID = id! + 1;
    }
  }
}