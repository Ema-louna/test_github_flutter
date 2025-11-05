import 'package:flutter/material.dart';

class BoatMain extends StatefulWidget {
  const BoatMain({super.key});

  @override
  State<BoatMain> createState() => _BoatMainState();
}

class _BoatMainState extends State<BoatMain> {
  // list that stores user-inserted boats
  final List<String> boats = [];

  // text controller for input field
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Boats for Sale')),
      body: ListPage(), // all list-related code in one function (per course guide)
    );
  }

  // ----------------- ListPage() -----------------
  Widget ListPage() {
    return Column(
      children: [
        // Row with Add button + TextField
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {
                  final text = _controller.text.trim();
                  if (text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a boat name!')),
                    );
                    return;
                  }
                  setState(() {
                    boats.add(text);
                    _controller.clear();
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Boat added! Total: ${boats.length}')),
                  );
                },
                child: const Text('Add Boat'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    labelText: 'Enter Boat Name',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) {
                    final text = _controller.text.trim();
                    if (text.isEmpty) return;
                    setState(() {
                      boats.add(text);
                      _controller.clear();
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Boat added! Total: ${boats.length}')),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // Expanded ListView builder
        Expanded(
          child: ListView.builder(
            itemCount: boats.length,
            itemBuilder: (context, index) {
              final boat = boats[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    boats.removeAt(index);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Removed "$boat"')),
                  );
                },
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Row ${index + 1}'),
                      Text(boat),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
