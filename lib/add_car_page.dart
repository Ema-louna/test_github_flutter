import 'package:flutter/material.dart';
import 'Car.dart';

class AddCarPage extends StatefulWidget {
  final Function(Car newCar) onAdd;

  const AddCarPage({super.key, required this.onAdd});

  @override
  State<AddCarPage> createState() => _AddCarPageState();
}

class _AddCarPageState extends State<AddCarPage> {
  final _name = TextEditingController();
  final _model = TextEditingController();
  final _year = TextEditingController();
  final _color = TextEditingController();
  final _description = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add New Car")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: _model,
              decoration: const InputDecoration(labelText: "Model"),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: _year,
              decoration: const InputDecoration(labelText: "Year"),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: _color,
              decoration: const InputDecoration(labelText: "Color"),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: _description,
              decoration: const InputDecoration(labelText: "Description"),
              maxLines: 4,
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                if (_name.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Name is required")),
                  );
                  return;
                }

                final car = Car(
                  Car.ID,
                  _name.text.trim(),
                  _model.text.trim(),
                  _year.text.trim(),
                  _color.text.trim(),
                  _description.text.trim(),
                );

                widget.onAdd(car);
                Navigator.pop(context);
              },
              child: const Text("Add Car"),
            ),
          ],
        ),
      ),
    );
  }
}
