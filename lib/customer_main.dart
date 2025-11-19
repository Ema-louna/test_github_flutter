import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'customer.dart';
import 'customer_dao.dart';
import 'database.dart';
import 'customer_detail_page.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Main customer management page
///
/// Allows users to add, view, and manage customers.
/// Supports responsive layout and multi-language.
class CustomerMain extends StatefulWidget {
  const CustomerMain({super.key});

  @override
  State<CustomerMain> createState() => _CustomerMainState();
}

class _CustomerMainState extends State<CustomerMain> {
  /// Text controller for first name input
  final TextEditingController _firstNameController = TextEditingController();
  /// Text controller for last name input
  final TextEditingController _lastNameController = TextEditingController();
  /// Text controller for address input
  final TextEditingController _addressController = TextEditingController();
  /// Text controller for date of birth input
  final TextEditingController _dobController = TextEditingController();
  /// Text controller for driver license input
  final TextEditingController _licenseController = TextEditingController();
  /// Encrypted storage for saving last customer data
  final EncryptedSharedPreferences _encryptedPrefs = EncryptedSharedPreferences();

  /// List of all customers loaded from database
  List<Customer> _customers = [];
  /// Database instance
  AppDatabase? _database;
  /// Data access object for customer operations
  CustomerDao? _customerDao;
  /// Loading state indicator
  bool _isLoading = true;
  /// Index of selected customer in tablet view
  int? _selectedIndex;
  /// Current locale for language support
  Locale _locale = const Locale('en');

  @override
  void initState() {
    super.initState();
    _initDatabase();
    _loadLastCustomerData();
  }

  /// Changes the application language
  ///
  /// [languageCode] Language code ('en' or 'fr')
  void _changeLanguage(String languageCode) {
    setState(() {
      _locale = Locale(languageCode);
    });
  }

  /// Initializes the database connection
  ///
  /// Sets up Floor database and loads existing customers.
  /// Supports web platform with sqflite_common_ffi_web.
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

  /// Adds a new customer to the database
  ///
  /// Validates all fields before adding.
  /// Saves customer data to encrypted storage.
  /// Updates the UI with the new customer list.
  Future<void> _addCustomer() async {
    if (_customerDao == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.translate('database_not_ready')!)),
      );
      return;
    }

    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _dobController.text.isEmpty ||
        _licenseController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.translate('all_fields_required')!)),
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
        SnackBar(content: Text('${AppLocalizations.of(context)!.translate('customer_added')!}: ${_customers.length}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  /// Loads last saved customer data from encrypted storage
  ///
  /// Pre-fills form fields with data from the last added customer.
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

  /// Saves customer data to encrypted storage
  ///
  /// [customer] The customer object to save
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

  /// Shows help dialog with usage instructions
  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => Localizations.override(
        context: dialogContext,
        locale: _locale,
        delegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        child: Builder(
          builder: (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.translate('instructions')!),
            content: Text(AppLocalizations.of(context)!.translate('help_text')!),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(AppLocalizations.of(context)!.translate('ok')!),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 600;

    return Localizations.override(
      context: context,
      locale: _locale,
      delegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      child: Builder(
        builder: (context) {
          if (_isLoading) {
            return Scaffold(
              appBar: AppBar(
                title: Text(AppLocalizations.of(context)!.translate('app_title')!),
                backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.info_outline),
                    onPressed: _showHelpDialog,
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.language),
                    onSelected: _changeLanguage,
                    itemBuilder: (BuildContext context) => [
                      const PopupMenuItem(
                        value: 'en',
                        child: Text('English'),
                      ),
                      const PopupMenuItem(
                        value: 'fr',
                        child: Text('Français'),
                      ),
                    ],
                  ),
                ],
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(AppLocalizations.of(context)!.translate('initializing')!),
                  ],
                ),
              ),
            );
          }

          return Scaffold(
            appBar: AppBar(
              title: Text(AppLocalizations.of(context)!.translate('app_title')!),
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              actions: [
                IconButton(
                  icon: const Icon(Icons.help_outline),
                  onPressed: _showHelpDialog,
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.language),
                  onSelected: _changeLanguage,
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem(
                      value: 'en',
                      child: Text('English'),
                    ),
                    const PopupMenuItem(
                      value: 'fr',
                      child: Text('Français'),
                    ),
                  ],
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _firstNameController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.translate('first_name')!,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _lastNameController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.translate('last_name')!,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.translate('address')!,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _dobController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.translate('date_of_birth')!,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _licenseController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.translate('driver_license')!,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                    onPressed: _addCustomer,
                    child: Text(AppLocalizations.of(context)!.translate('add_customer')!),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${AppLocalizations.of(context)!.translate('total_customers')!}: ${_customers.length}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),

                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: _customers.isEmpty
                              ? Center(
                            child: Text(
                              AppLocalizations.of(context)!.translate('no_customers')!,
                              style: const TextStyle(fontSize: 16, color: Colors.grey),
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
                                      AppLocalizations.of(context)!.translate('customer_details')!,
                                      style: Theme.of(context).textTheme.headlineSmall,
                                    ),
                                    const SizedBox(height: 20),
                                    _buildDetailRow('ID', '${_customers[_selectedIndex!].id}'),
                                    _buildDetailRow(
                                      AppLocalizations.of(context)!.translate('first_name')!,
                                      _customers[_selectedIndex!].firstName,
                                    ),
                                    _buildDetailRow(
                                      AppLocalizations.of(context)!.translate('last_name')!,
                                      _customers[_selectedIndex!].lastName,
                                    ),
                                    _buildDetailRow(
                                      AppLocalizations.of(context)!.translate('address')!,
                                      _customers[_selectedIndex!].address,
                                    ),
                                    _buildDetailRow(
                                      AppLocalizations.of(context)!.translate('date_of_birth')!,
                                      _customers[_selectedIndex!].dateOfBirth,
                                    ),
                                    _buildDetailRow(
                                      AppLocalizations.of(context)!.translate('driver_license')!,
                                      _customers[_selectedIndex!].driverLicense,
                                    ),
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
        },
      ),
    );
  }

  /// Builds a detail row widget
  ///
  /// [label] The field label
  /// [value] The field value
  /// Returns a formatted widget displaying label and value
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