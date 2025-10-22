import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'car_detail_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  var carsBox = await Hive.openBox('carsBox');
  runApp(MyApp(carsBox: carsBox));
}
class MyApp extends StatelessWidget {
  final Box carsBox;
  const MyApp({super.key, required this.carsBox});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page', carsBox: carsBox),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  final Box carsBox;
  const MyHomePage({super.key, required this.title, required this.carsBox});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _textController = TextEditingController();
  int? _selectedIndex;
  Box get carsBox => Hive.box('carsBox');

  void _addCar() {
    if (_textController.text.isNotEmpty) {
      final newCar = {
        'name': _textController.text,
        'model': 'Unknown',
        'year': '2025',
        'color': 'N/A',
        'description': 'No details added yet',
      };

      widget.carsBox.add(newCar); // store as a new car
      _textController.clear();
      setState(() {});
      // SHOW SNACKBAR
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Car added: ${newCar['name']}'),
              duration: Duration(seconds: 3),
          ),
      );
    }
  }

  Map _getCar(dynamic carRaw) {
    if (carRaw is Map) return carRaw;
    // convert old Strings or any other type to Map
    return {
      'name': carRaw.toString(),
      'model': 'Unknown',
      'year': '2025',
      'color': 'N/A',
      'description': 'No details added yet',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
      icon: Icon(Icons.info_outline),
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text('Instructions'),
              content: Text(
                  'To add a car, type the name and press "Add Car".\n'
                      'Select a car to view, update, or delete it.\n'
                      'On a large screen, details appear beside the list.'
              ),

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Ok'),
            )
          ],
            ),
            );
                },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                labelText: 'Enter car name/model',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addCar,
              child: const Text('Add Car'),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: ValueListenableBuilder(
                      valueListenable: widget.carsBox.listenable(),
                      builder: (context, Box box, _) {
                        final cars = box.values.toList();
                        return ListView.builder(
                          itemCount: cars.length,
                          itemBuilder: (context, index) {
                            final car = _getCar(cars[index]);
                            return ListTile(
                              title: Text(car['name']),
                              selected: _selectedIndex == index,
                              onTap: () {
                                final car = _getCar(widget.carsBox.getAt(index));
                                final isWideScreen = MediaQuery.of(context).size.width >= 600;

                                if (isWideScreen) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Selected car: ${car['name']}'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                  setState(() {
                                    _selectedIndex = index;
                                  });
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => CarDetailPage(
                                        index: index,
                                        carData: car,
                                      ),
                                    ),
                                  ).then((_) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Selected car: ${car['name']}'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                    setState(() {});
                                  });
                                }

                              },
                            );
                          },
                        );
                      },
                    ),
                  ),

                  // Right side: detail panel (only on wide screens)
                  if (_selectedIndex != null && MediaQuery.of(context).size.width >= 600)
                    Expanded(
                      flex: 3,
                      child: CarDetailPage(
                        key: ValueKey(_selectedIndex),
                        index: _selectedIndex!,
                        carData: _getCar(widget.carsBox.getAt(_selectedIndex!)),
                        fullScreen: false,
                      ),

                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
