import 'package:floor/floor.dart';
import 'customer.dart';

/// Data Access Object for Customer operations
///
/// Provides methods to interact with the Customer table
/// in the database including CRUD operations.
@dao
abstract class CustomerDao {
  /// Retrieves all customers from the database
  ///
  /// Returns a Future containing a list of all Customer objects
  @Query('SELECT * FROM Customer')
  Future<List<Customer>> findAllCustomers();

  /// Inserts a new customer into the database
  ///
  /// [customer] The customer object to insert
  @insert
  Future<void> insertCustomer(Customer customer);

  /// Deletes a customer from the database
  ///
  /// [customer] The customer object to delete
  @delete
  Future<void> deleteCustomer(Customer customer);

  /// Updates an existing customer in the database
  ///
  /// [customer] The customer object with updated information
  /// Uses replace strategy for conflicts
  @Update(onConflict: OnConflictStrategy.replace)
  Future<void> updateCustomer(Customer customer);
}