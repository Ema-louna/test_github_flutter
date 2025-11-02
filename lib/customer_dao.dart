import 'package:floor/floor.dart';
import 'customer.dart';

@dao
abstract class CustomerDao {
  @Query('SELECT * FROM Customer')
  Future<List<Customer>> findAllCustomers();

  @insert
  Future<void> insertCustomer(Customer customer);

  @delete
  Future<void> deleteCustomer(Customer customer);

  @Update(onConflict: OnConflictStrategy.replace)
  Future<void> updateCustomer(Customer customer);
}