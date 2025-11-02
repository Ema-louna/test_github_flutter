import 'package:flutter/material.dart';

class CustomerMain extends StatefulWidget {
  const CustomerMain({super.key});

  @override
  State<CustomerMain> createState() => _CustomerMainState();
}

class _CustomerMainState extends State<CustomerMain> {
  final TextEditingController _controller = TextEditingController();
  List<String> _customers = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer List'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // TextField and Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'Customer name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  onPressed: () {
                    setState(() {
                      if (_controller.text.isNotEmpty) {
                        _customers.add(_controller.text);
                        _controller.clear();
                      }
                    });
                  },
                  child: const Text('Add Customer'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // ListView
            Expanded(
              child: ListView.builder(
                itemCount: _customers.length,
                itemBuilder: (context, rowNum) {
                  return ListTile(
                    title: Text(
                      _customers[rowNum],
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    onTap: () {
                      // We'll add details view in later steps
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