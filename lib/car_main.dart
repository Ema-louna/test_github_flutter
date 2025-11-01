import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';


class CarsMain extends StatefulWidget {
  const CarsMain({super.key});

  @override
  State<CarsMain> createState() => _CarsMainState();
}

class _CarsMainState extends State<CarsMain> {
  late Database _db;
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _cars = [];

  @override
  void initState() {
    super.initState();
    _initDb();
    _loadLastTypedCar();
  }

  Future<void> _initDb() async {
    final path = join(await getDatabasesPath(), 'cars.db');
    _db = await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE cars(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT
        )
      ''');
    });
    _loadCars();
  }

  Future<void> _loadCars() async {
    final cars = await _db.query('cars');
    setState(() => _cars = cars);
  }

  Future<void> _addCar(String name) async {
    if (name.isEmpty) return;
    await _db.insert('cars', {'name': name});
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastCar', name); // save last typed car
    _controller.clear();
    _loadCars();
    ScaffoldMessenger.of(context as BuildContext).showSnackBar(
      SnackBar(content: Text('Car added: $name')),
    );
  }

  Future<void> _loadLastTypedCar() async {
    final prefs = await SharedPreferences.getInstance();
    final lastCar = prefs.getString('lastCar') ?? '';
    _controller.text = lastCar;
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 600;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cars'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Instructions'),
                  content: const Text('Type a car name and click Add.'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'))
                  ],
                ),
              );
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _controller, decoration: const InputDecoration(labelText: 'Car name')),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: () => _addCar(_controller.text), child: const Text('Add Car')),
            const SizedBox(height: 10),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: ListView.builder(
                      itemCount: _cars.length,
                      itemBuilder: (context, index) {
                        final car = _cars[index];
                        return ListTile(
                          title: Text(car['name']),
                          onTap: () {
                            if (isWide) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Selected: ${car['name']}')));
                            } else {
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: Text(car['name']),
                                  content: Text('Details about ${car['name']}'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))
                                  ],
                                ),
                              );
                            }
                          },
                        );
                      },
                    ),
                  ),
                  if (isWide && _cars.isNotEmpty)
                    Expanded(
                      child: Container(
                        color: Colors.grey[200],
                        child: Center(child: Text('Select a car to see details')),
                      ),
                    )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
