import 'package:flutter/material.dart';

class CarDetailPage extends StatefulWidget {
  final Map carData;
  final bool fullScreen;
  final Function(Map updatedCar)? onUpdate;

  const CarDetailPage({
    super.key,
    required this.carData,
    this.fullScreen = true,
    this.onUpdate,
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

    _name = TextEditingController(text: widget.carData["name"]);
    _model = TextEditingController(text: widget.carData["model"]);
    _year = TextEditingController(text: widget.carData["year"]);
    _color = TextEditingController(text: widget.carData["color"]);
    _description = TextEditingController(text: widget.carData["description"]);
  }

  Map<String, dynamic> _collectUpdatedCar() {
    return {
      "id": widget.carData["id"],
      "name": _name.text,
      "model": _model.text,
      "year": _year.text,
      "color": _color.text,
      "description": _description.text,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.fullScreen
          ? AppBar(
        title: Text(
          _name.text,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      )
          : null,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _name,
                decoration: const InputDecoration(
                  labelText: "Car Name",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),

              TextField(
                controller: _model,
                decoration: const InputDecoration(
                  labelText: "Model",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),

              TextField(
                controller: _year,
                decoration: const InputDecoration(
                  labelText: "Year",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),

              TextField(
                controller: _color,
                decoration: const InputDecoration(
                  labelText: "Color",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),

              TextField(
                controller: _description,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onUpdate?.call(_collectUpdatedCar());
                      },
                      child: const Text("Save"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onUpdate?.call({"delete": widget.carData["id"]});
                        if (widget.fullScreen) Navigator.pop(context);
                      },
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
