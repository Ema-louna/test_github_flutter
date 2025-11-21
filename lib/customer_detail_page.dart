import 'package:flutter/material.dart';
import 'customer.dart';

/// Detail page displaying full customer information
///
/// Shows all fields of a selected customer in a
/// full-screen view on phones.
class CustomerDetailPage extends StatelessWidget {
  /// The customer to display
  final Customer customer;

  /// Creates a CustomerDetailPage
  ///
  /// [customer] The customer object to display
  const CustomerDetailPage({
    super.key,
    required this.customer,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${customer.firstName} ${customer.lastName}'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(context, 'ID', '${customer.id}'),
            _buildDetailRow(context, 'First Name', customer.firstName),
            _buildDetailRow(context, 'Last Name', customer.lastName),
            _buildDetailRow(context, 'Address', customer.address),
            _buildDetailRow(context, 'Date of Birth', customer.dateOfBirth),
            _buildDetailRow(context, 'Driver License', customer.driverLicense),
          ],
        ),
      ),
    );
  }

  /// Builds a detail row widget
  ///
  /// [context] Build context for theming
  /// [label] The field label
  /// [value] The field value
  /// Returns a formatted widget displaying label and value
  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
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
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}