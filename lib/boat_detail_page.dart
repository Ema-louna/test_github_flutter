import 'package:flutter/material.dart';
import 'boat_item.dart';

class BoatDetailPage extends StatelessWidget {
  final BoatItem boat;
  const BoatDetailPage({super.key, required this.boat});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Boat Details'),
        actions: [
          IconButton(
            tooltip: 'Help',
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              // ✅ detail screen AlertDialog
              showDialog(
                context: context,
                builder: (_) => const AlertDialog(
                  title: Text('Boat Details Help'),
                  content: Text(
                      'This screen shows the details of the selected boat.\n\n'
                          'Use the back button to return to the list.'),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _DetailPanel(boat: boat),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // ✅ detail screen Snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Feature coming soon!')),
          );
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}

class _DetailPanel extends StatelessWidget {
  final BoatItem boat;
  const _DetailPanel({required this.boat});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Boat Details', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        _row('ID', boat.id?.toString() ?? '-'),
        _row('Name', boat.name),
      ],
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
