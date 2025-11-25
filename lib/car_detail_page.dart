import 'package:flutter/material.dart';
import 'Car.dart';

class CarDetailPage extends StatefulWidget {
  final Car car;
  final bool fullScreen;
  final Future<void> Function(Car updatedCar, {bool delete}) onUpdate;

  const CarDetailPage({
    super.key,
    required this.car,
    required this.onUpdate,
    this.fullScreen = true,
  });

  @override
  State<CarDetailPage> createState() => _CarDetailPageState();
}

class _CarDetailPageState extends State<CarDetailPage> {
  late TextEditingController _name;
  late TextEditingController _model;
  late TextEditingController _year;
  late TextEditingController _color;
  late TextEditingController _description;

  @override
  void initState() {
    super.initState();

    _name = TextEditingController(text: widget.car.name);
    _model = TextEditingController(text: widget.car.model);
    _year = TextEditingController(text: widget.car.year);
    _color = TextEditingController(text: widget.car.color);
    _description = TextEditingController(text: widget.car.description);
  }

  Car _getUpdatedCar() {
    return Car(
      widget.car.id,
      _name.text,
      _model.text,
      _year.text,
      _color.text,
      _description.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.fullScreen
          ? AppBar(
        title: Text(_name.text),
      )
          : null,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _name,
                decoration: const InputDecoration(labelText: "Name", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),

              TextField(
                controller: _model,
                decoration: const InputDecoration(labelText: "Model", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),

              TextField(
                controller: _year,
                decoration: const InputDecoration(labelText: "Year", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),

              TextField(
                controller: _color,
                decoration: const InputDecoration(labelText: "Color", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),

              TextField(
                controller: _description,
                maxLines: 5,
                decoration: const InputDecoration(labelText: "Description", border: OutlineInputBorder()),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final updated = _getUpdatedCar();
                        await widget.onUpdate(updated, delete: false);
                        if (widget.fullScreen) Navigator.pop(context);
                      },
                      child: const Text("Save"),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final updated = _getUpdatedCar();
                        await widget.onUpdate(updated, delete: true);
                        if (widget.fullScreen) Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text("Delete"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
