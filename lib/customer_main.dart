import 'package:flutter/material.dart';

class CustomerMain extends StatefulWidget {
  const CustomerMain({super.key});

  @override
  State<CustomerMain> createState() => _CustomerMainState();
}

class _CustomerMainState extends State<CustomerMain> {
  // Controllers for all 5 fields
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _licenseController = TextEditingController();

  // List to store customers (as Maps with all fields)
  List<Map<String, String>> _customers = [];

  void _addCustomer() {
    // Validate: check that all fields have a value
    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _dobController.text.isEmpty ||
        _licenseController.text.isEmpty) {
      // Show error if any field is empty
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields are required!')),
      );
      return;
    }

    // Add customer to list
    setState(() {
      _customers.add({
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'address': _addressController.text,
        'dateOfBirth': _dobController.text,
        'driverLicense': _licenseController.text,
      });

      // Clear all fields after adding
      _firstNameController.clear();
      _lastNameController.clear();
      _addressController.clear();
      _dobController.clear();
      _licenseController.clear();
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Customer added successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer List'),
        backgroundColor: Theme
            .of(context)
            .colorScheme
            .inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // All 5 input fields
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

            // Add Customer Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme
                    .of(context)
                    .colorScheme
                    .onPrimary,
              ),
              onPressed: _addCustomer,
              child: const Text('Add Customer'),
            ),
            const SizedBox(height: 10),

            // ListView to display customers
            Expanded(
              child: ListView.builder(
                itemCount: _customers.length,
                itemBuilder: (context, index) {
                  final customer = _customers[index];
                  return ListTile(
                    title: Text(
                      '${customer['firstName']} ${customer['lastName']}',
                      style: Theme
                          .of(context)
                          .textTheme
                          .bodyLarge,
                    ),
                    subtitle: Text(customer['address'] ?? ''),
                    onTap: () {
                      // Show customer details when tapped
                      showDialog(
                        context: context,
                        builder: (_) =>
                            AlertDialog(
                              title: Text(
                                  '${customer['firstName']} ${customer['lastName']}'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Address: ${customer['address']}'),
                                  Text(
                                      'Date of Birth: ${customer['dateOfBirth']}'),
                                  Text(
                                      'Driver License: ${customer['driverLicense']}'),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Close'),
                                )
                              ],
                            ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}