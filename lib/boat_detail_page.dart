import 'package:flutter/material.dart';
import 'boat_item.dart';

class BoatDetailPage extends StatelessWidget {
  final BoatItem boat;
  const BoatDetailPage({super.key, required this.boat});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Boat Details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _DetailPanel(boat: boat),
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
