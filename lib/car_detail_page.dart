import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class CarDetailPage extends StatefulWidget {
  final int index;
  final Map carData;
  final bool fullScreen;

  const CarDetailPage({
    super.key,
    required this.index,
    required this.carData,
    this.fullScreen = true,
  });

  @override
  State<CarDetailPage> createState() => _CarDetailPageState();
}

class _CarDetailPageState extends State<CarDetailPage> {
  late Box carsBox;

  // Controllers for each field
  late TextEditingController _nameController;
  late TextEditingController _modelController;
  late TextEditingController _yearController;
  late TextEditingController _colorController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    carsBox = Hive.box('carsBox');

    _nameController = TextEditingController(text: widget.carData['name']);
    _modelController = TextEditingController(text: widget.carData['model']);
    _yearController = TextEditingController(text: widget.carData['year']);
    _colorController = TextEditingController(text: widget.carData['color']);
    _descriptionController =
        TextEditingController(text: widget.carData['description']);
  }

  @override
  void didUpdateWidget(covariant CarDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.carData != widget.carData) {
      _nameController.text = widget.carData['name'];
      _modelController.text = widget.carData['model'];
      _yearController.text = widget.carData['year'];
      _colorController.text = widget.carData['color'];
      _descriptionController.text = widget.carData['description'];
    }
  }



  void _updateCar() {
    final updatedCar = {
      'name': _nameController.text,
      'model': _modelController.text,
      'year': _yearController.text,
      'color': _colorController.text,
      'description': _descriptionController.text,

    };

    carsBox.putAt(widget.index, updatedCar);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Car updated: ${_nameController.text}')),
    );

    if (widget.fullScreen) {
      Navigator.pop(context);
    } else {
      setState(() {});
    }
  }

  void _deleteCar() async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure to delete this car?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      carsBox.deleteAt(widget.index);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Car deleted successfully')),
      );

      if (widget.fullScreen) {
        Navigator.pop(context);
      } else {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.fullScreen
          ? AppBar(title: Text('Details: ${_nameController.text}'))
          : null,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Car Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _modelController,
              decoration: const InputDecoration(
                labelText: 'Model',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _yearController,
              decoration: const InputDecoration(
                labelText: 'Year',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _colorController,
              decoration: const InputDecoration(
                labelText: 'Color',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateCar,
              child: const Text('Save Changes'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _deleteCar,
              child: const Text('Delete Car'),
            ),
          ],
        ),
      ),
    );
  }
}
