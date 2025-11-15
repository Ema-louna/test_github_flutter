import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'customer.dart';
import 'customer_dao.dart';
import 'database.dart';
import 'customer_detail_page.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';

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
  final EncryptedSharedPreferences _encryptedPrefs = EncryptedSharedPreferences();

  List<Customer> _customers = [];
  AppDatabase? _database;
  CustomerDao? _customerDao;
  bool _isLoading = true;
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _initDatabase();
    _loadLastCustomerData();
  }

  Future<void> _initDatabase() async {
    try {
      print('Initializing database... kIsWeb = $kIsWeb');

      if (kIsWeb) {
        sqflite.databaseFactory = databaseFactoryFfiWeb;
      }

      final database = await $FloorAppDatabase
          .databaseBuilder('customer_database.db')
          .build();

      _database = database;
      _customerDao = database.customerDao;

      final customers = await _customerDao!.findAllCustomers();

      setState(() {
        _customers = customers;
        _isLoading = false;
      });
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
      final customer = Customer(
        Customer.ID++,
        _firstNameController.text,
        _lastNameController.text,
        _addressController.text,
        _dobController.text,
        _licenseController.text,
      );

      await _customerDao!.insertCustomer(customer);
      await _saveLastCustomerData(customer);

      final customers = await _customerDao!.findAllCustomers();

      setState(() {
        _customers = customers;
      });

      _firstNameController.clear();
      _lastNameController.clear();
      _addressController.clear();
      _dobController.clear();
      _licenseController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Customer added successfully! Total: ${_customers.length}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _loadLastCustomerData() async {
    try {
      final firstName = await _encryptedPrefs.getString('lastFirstName');
      final lastName = await _encryptedPrefs.getString('lastLastName');
      final address = await _encryptedPrefs.getString('lastAddress');
      final dob = await _encryptedPrefs.getString('lastDOB');
      final license = await _encryptedPrefs.getString('lastLicense');

      if (firstName.isNotEmpty) {
        setState(() {
          _firstNameController.text = firstName;
          _lastNameController.text = lastName;
          _addressController.text = address;
          _dobController.text = dob;
          _licenseController.text = license;
        });
      }
    } catch (e) {
      print('Error loading encrypted data: $e');
    }
  }

  Future<void> _saveLastCustomerData(Customer customer) async {
    try {
      await _encryptedPrefs.setString('lastFirstName', customer.firstName);
      await _encryptedPrefs.setString('lastLastName', customer.lastName);
      await _encryptedPrefs.setString('lastAddress', customer.address);
      await _encryptedPrefs.setString('lastDOB', customer.dateOfBirth);
      await _encryptedPrefs.setString('lastLicense', customer.driverLicense);
    } catch (e) {
      print('Error saving encrypted data: $e');
    }
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Instructions'),
        content: const Text(
            'Fill in all customer fields and click Add Customer.\n'
                'Tap a customer to view details.\n'
                'On large screens, details appear beside the list.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 600;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Customer List'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: _showHelpDialog,
            )
          ],
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
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelpDialog,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
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

            Expanded(
              child: Row(
                children: [
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
                                setState(() => _selectedIndex = index);
                              } else {
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
