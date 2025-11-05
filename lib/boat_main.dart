import 'package:flutter/material.dart';

class BoatMain extends StatefulWidget {
  const BoatMain({super.key});

  @override
  State<BoatMain> createState() => _BoatMainState();
}

class _BoatMainState extends State<BoatMain> {
  // List that holds items inserted by the user
  final List<String> words = <String>[];

  // TextField controller
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Boats for Sale')),
      // per course notes: put the whole list area in a separate function
      body: ListPage(),
    );
  }

  /// Using functions to create components (as in the course material)
  /// Returns: Column( Row(Add + TextField), Expanded(ListView.builder) )
  Widget ListPage() {
    return Column(
      children: [
        // Row with Add button and TextField
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                child: const Text("Add item"),
                onPressed: () {
                  setState(() {
                    // add current text to the list
                    final text = _controller.value.text.trim();
                    if (text.isNotEmpty) {
                      words.add(text);
                      _controller.text = "";
                    }
                  });
                },
              ),
              // NOTE: param is `controller` (course snippet said inputController)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'Enter boat text',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Expanded so ListView has bounded height inside Column
        Expanded(
          child: ListView.builder(
            itemCount: words.length, // number of rows
            itemBuilder: (context, rowNum) {
              // A row: delete on tap (GestureDetector)
              return GestureDetector(
                onTap: () {
                  setState(() {
                    words.removeAt(rowNum);
                  });
                },
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text("Row number: $rowNum"),
                      Text(words[rowNum]),
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
