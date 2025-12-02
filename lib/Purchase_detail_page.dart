import 'package:flutter/material.dart';
import 'Purchase.dart';
import 'PurchaseDao.dart';

/// Full details page for a selected purchase offer
///
/// Works as a standalone page (phone)
/// and also as a right-side detail panel (tablet/desktop)
class PurchaseDetailPage extends StatelessWidget {
  final Purchase purchase;
  final PurchaseDao dao;
  final VoidCallback onSaved;

  const PurchaseDetailPage({
    super.key,
    required this.purchase,
    required this.dao,
    required this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Purchase #${purchase.id}"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _buildContent(context),
    );
  }

  /// MAIN CONTENT (extracted so desktop version can reuse it)
  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          _buildRow(context, "Customer ID", purchase.customerID),
          _buildRow(context, "Vehicle ID", purchase.vehicleId),
          _buildRow(context, "Offered Price", "\$${purchase.price}"),
          _buildRow(context, "Status", purchase.status),
          _buildRow(context, "Created At", purchase.dateOfOffer ?? "N/A"),
          const SizedBox(height: 20),

          // ACTION BUTTONS
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text("Edit"),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      "/purchase_form",
                      arguments: purchase,
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.delete),
                  label: const Text("Delete"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    await dao.deletePurchase(purchase);
                    onSaved();

                    // Close page if this is shown as a full page
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  /// Builds a consistent UI row for each purchase field
  Widget _buildRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              )),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          )
        ],
      ),
    );
  }
}
