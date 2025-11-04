import 'package:flutter/material.dart';
import 'customer.dart';

class CustomerDetailPage extends StatelessWidget {
  final Customer customer;

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