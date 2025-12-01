import 'package:flutter/material.dart';

/// Model for a purchase item
class PurchaseItem {
  final int id;
  final String name;

  PurchaseItem(this.id, this.name);
}

/// Purchase Section main page
class PurchaseOfferMain extends StatefulWidget {
  const PurchaseOfferMain({super.key});

  @override
  State<PurchaseOfferMain> createState() => _PurchaseOfferMainState();
}

class _PurchaseOfferMainState extends State<PurchaseOfferMain> {
  /// Controller for new item input
  final TextEditingController _itemController = TextEditingController();

  /// List of all items inserted by the user
  final List<PurchaseItem> _items = [];

  /// Auto-increment ID for items
  int _nextId = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Purchases"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Input + Add button
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _itemController,
                    decoration: const InputDecoration(
                      labelText: 'Enter item name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _addItem,
                  child: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ListView showing inserted items
            Expanded(
              child: _items.isEmpty
                  ? const Center(
                child: Text(
                  'No items yet',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
                  : ListView.builder(
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return Card(
                    child: ListTile(
                      title: Text(item.name),
                      onTap: () {
                        // Details view to be implemented later
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Adds a new item to the list
  void _addItem() {
    final name = _itemController.text.trim();
    if (name.isEmpty) return;

    setState(() {
      _items.add(PurchaseItem(_nextId++, name));
      _itemController.clear();
    });
  }
}
