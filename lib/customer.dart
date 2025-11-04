import 'package:floor/floor.dart';

@entity
class Customer {
  @primaryKey
  final int? id;

  final String firstName;
  final String lastName;
  final String address;
  final String dateOfBirth;
  final String driverLicense;

  static int ID = 1;

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