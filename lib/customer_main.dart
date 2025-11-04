import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'customer.dart';
import 'customer_dao.dart';
import 'database.dart';
import 'customer_detail_page.dart';

class CustomerMain extends StatefulWidget {
  const CustomerMain({super.key});

  @override
  State<CustomerMain> createState() => _CustomerMainState();
}

class _CustomerMainState extends State<CustomerMain> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _licenseController = TextEditingController();

  List<Customer> _customers = [];
  AppDatabase? _database;
  CustomerDao? _customerDao;
  bool _isLoading = true;
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    try {
      print('Initializing database... kIsWeb = $kIsWeb');

      // CRITICAL: Must set factory BEFORE any database operations
      if (kIsWeb) {
        print('Setting up web database factory...');
        sqflite.databaseFactory = databaseFactoryFfiWeb;
      }

      print('Creating database...');

      final database = await $FloorAppDatabase
          .databaseBuilder('customer_database.db')
          .build();

      print('Database created successfully');

      _database = database;
      _customerDao = database.customerDao;

      final customers = await _customerDao!.findAllCustomers();

      setState(() {
        _customers = customers;
        _isLoading = false;
      });

      print('Database initialized. Total: ${_customers.length}');
    } catch (e, stackTrace) {
      print('Error initializing database: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addCustomer() async {
    if (_customerDao == null) {
      print('Database not ready');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Database not ready. Please wait...')),
      );
      return;
    }

    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _dobController.text.isEmpty ||
        _licenseController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields are required!')),
      );
      return;
    }

    try {
      // Create new customer with auto-incremented ID
      final customer = Customer(
        Customer.ID++,
        _firstNameController.text,
        _lastNameController.text,
        _addressController.text,
        _dobController.text,
        _licenseController.text,
      );

      print('Adding customer: ${customer.firstName} ${customer.lastName} (ID: ${customer.id})');

      // Insert into database
      await _customerDao!.insertCustomer(customer);

      print('Customer inserted successfully');

      // Reload customers from database
      final customers = await _customerDao!.findAllCustomers();

      print('After insert: ${customers.length} customers in database');

      setState(() {
        _customers = customers;
      });

      // Clear fields
      _firstNameController.clear();
      _lastNameController.clear();
      _addressController.clear();
      _dobController.clear();
      _licenseController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Customer added successfully! Total: ${_customers.length}')),
      );
    } catch (e) {
      print('Error adding customer: $e');
      print('Error type: ${e.runtimeType}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if screen is wide (tablet/desktop)
    final isWide = MediaQuery.of(context).size.width >= 600;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Customer List'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Initializing database...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer List'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Input fields (same as before)
            TextField(
              controller: _firstNameController,
              decoration: const InputDecoration(
                labelText: 'First Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _lastNameController,
              decoration: const InputDecoration(
                labelText: 'Last Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _dobController,
              decoration: const InputDecoration(
                labelText: 'Date of Birth (YYYY-MM-DD)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _licenseController,
              decoration: const InputDecoration(
                labelText: 'Driver License #',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              onPressed: _addCustomer,
              child: const Text('Add Customer'),
            ),
            const SizedBox(height: 10),
            Text(
              'Total customers: ${_customers.length}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),

            // RESPONSIVE LAYOUT: Row for tablet, Column for phone
            Expanded(
              child: Row(
                children: [
                  // LEFT SIDE: ListView (always shown)
                  Expanded(
                    flex: 2,
                    child: _customers.isEmpty
                        ? const Center(
                      child: Text(
                        'No customers yet. Add one to get started!',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                        : ListView.builder(
                      itemCount: _customers.length,
                      itemBuilder: (context, index) {
                        final customer = _customers[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            title: Text(
                              '${customer.firstName} ${customer.lastName}',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            subtitle: Text(customer.address),
                            selected: _selectedIndex == index,
                            onTap: () {
                              if (isWide) {
                                // TABLET: Show details in side panel
                                setState(() => _selectedIndex = index);
                              } else {
                                // PHONE: Navigate to full-screen detail page
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CustomerDetailPage(
                                      customer: customer,
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),

                  // RIGHT SIDE: Detail panel (only on wide screens)
                  if (isWide && _selectedIndex != null)
                    Expanded(
                      flex: 3,
                      child: Container(
                        color: Colors.grey[200],
                        padding: const EdgeInsets.all(16),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Customer Details',
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 20),
                              _buildDetailRow('ID', '${_customers[_selectedIndex!].id}'),
                              _buildDetailRow('First Name', _customers[_selectedIndex!].firstName),
                              _buildDetailRow('Last Name', _customers[_selectedIndex!].lastName),
                              _buildDetailRow('Address', _customers[_selectedIndex!].address),
                              _buildDetailRow('Date of Birth', _customers[_selectedIndex!].dateOfBirth),
                              _buildDetailRow('Driver License', _customers[_selectedIndex!].driverLicense),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

// Helper method to build detail rows
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}