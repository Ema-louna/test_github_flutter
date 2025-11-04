import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'car_detail_page.dart';

class CarsMain extends StatefulWidget {
  const CarsMain({super.key});

  @override
  State<CarsMain> createState() => _CarsMainState();
}

class _CarsMainState extends State<CarsMain> {
  late Database _db;
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _cars = [];
  int? _selectedIndex;




  @override
  void initState() {
    super.initState();
    _initDb();
    _loadLastTypedCar();
  }

  Future<void> _initDb() async {
    // Initialize FFI for desktop
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

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

    try {

      await _db.insert('cars', {'name': name});
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('lastCar', name);
      _controller.clear();
      final cars = await _db.query('cars');
      setState(() {
        _cars = cars;
      });
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        SnackBar(content: Text('Car added: $name')),
      );
    } catch (e) {
      print('Error adding car: $e');
    }
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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Car name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                final name = _controller.text.trim();
                if (name.isEmpty) return;
                await _db.insert('cars', {'name': name});
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('lastCar', name);
                _controller.clear();

                final cars = await _db.query('cars');
                setState(() {
                  _cars = cars;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Car added: $name')),
                );
              },
              child: const Text('Add Car'),


            ),
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
                          title: Text(
                            car['name'],
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          onTap: () {

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('You selected: ${car['name']}'),
                                duration: Duration(seconds: 2),
                              ),
                            );


                            if (isWide){
                              setState(() {
                                _selectedIndex = index;
                              });
                            } else{
                              final carData = _cars[index];
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CarDetailPage(
                                    carData: carData,
                                    onUpdate: (updatedCar) async {
                                      if (updatedCar.containsKey('delete')) {
                                        await _db.delete(
                                          'cars',
                                          where: 'id = ?',
                                          whereArgs: [updatedCar['delete']],
                                        );
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Car deleted successfully')),
                                        );
                                      } else {
                                        final dbCar = Map<String, Object?>.from(updatedCar);
                                        await _db.update(
                                          'cars',
                                          dbCar,
                                          where: 'id = ?',
                                          whereArgs: [updatedCar['id']],
                                        );
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Car updated: ${updatedCar['name']}')),
                                        );

                                      }

                                      _loadCars();
                                      setState(() => _selectedIndex = null);
                                    },
                                  ),
                                ),
                              );
                            }
                          },
                        );
                      },
                    ),
                  ),
                  if (isWide)
                    Expanded(
                      child: _selectedIndex != null
                          ? CarDetailPage(
                        carData: _cars[_selectedIndex!],
                        fullScreen: false,
                        onUpdate: (updatedCar) async {
                          if (updatedCar.containsKey('delete')) {
                            await _db.delete(
                              'cars',
                              where: 'id = ?',
                              whereArgs: [updatedCar['delete']],
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Car deleted successfully')),
                            );
                          } else {
                            final dbCar = Map<String, Object?>.from(updatedCar);
                            await _db.update(
                              'cars',
                              dbCar,
                              where: 'id = ?',
                              whereArgs: [updatedCar['id']],
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Car updated: ${updatedCar['name']}')),
                            );

                          }

                          _loadCars();
                          setState(() => _selectedIndex = null);
                        },
                      )
                          : Center(
                        child: Text(
                          'Select a car to see details',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),



                    ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
