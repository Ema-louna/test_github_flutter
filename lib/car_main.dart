import 'package:flutter/material.dart';
import 'Car.dart';
import 'CarDAO.dart';
import 'CarDatabase.dart';
import 'car_detail_page.dart';
import 'add_car_page.dart';

class CarsMain extends StatefulWidget {
  const CarsMain({super.key});

  @override
  State<CarsMain> createState() => _CarsMainState();
}

class _CarsMainState extends State<CarsMain> {
  CarDatabase? _database;
  CarDAO? _dao;
  List<Car> _cars = [];
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _initFloorDb();
  }

  Future<void> _initFloorDb() async {
    final db = await $FloorCarDatabase.databaseBuilder("cars.db").build();
    _database = db;
    _dao = db.carDao;

    _loadCars();
  }

  Future<void> _loadCars() async {
    if (_dao == null) return;
    final cars = await _dao!.getAllCars();
    setState(() => _cars = cars);
  }

  void _openDetail(Car car, bool isWide) {
    if (!isWide) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CarDetailPage(
            car: car,
            onUpdate: _updateCarFromDetails,
          ),
        ),
      );
    } else {
      setState(() => _selectedIndex = _cars.indexOf(car));
    }
  }

  Future<void> _updateCarFromDetails(Car updatedCar, {bool delete = false}) async {
    if (delete) {
      await _dao!.deleteCar(updatedCar);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Car deleted")),
      );
    } else {
      await _dao!.updateCar(updatedCar);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Updated: ${updatedCar.name}")),
      );
    }

    _selectedIndex = null;
    _loadCars();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Cars"),
      ),

      // ADD CAR BUTTON
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddCarPage(
                onAdd: (Car newCar) async {
                  await _dao!.insertCar(newCar);
                  _loadCars();
                },
              ),
            ),
          );
        },
      ),

      body: Row(
        children: [
          // LEFT PANEL: CAR LIST
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: _cars.length,
                      itemBuilder: (context, index) {
                        final car = _cars[index];
                        return ListTile(
                          title: Text(car.name),
                          subtitle: Text(
                            car.model.isEmpty ? "No model" : car.model,
                            style: const TextStyle(fontSize: 13),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () => _openDetail(car, isWide),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // RIGHT PANEL: CAR DETAILS (WIDE SCREEN ONLY)
          if (isWide)
            Expanded(
              child: _selectedIndex == null
                  ? const Center(
                child: Text(
                  "Select a car",
                  style: TextStyle(fontSize: 18),
                ),
              )
                  : CarDetailPage(
                car: _cars[_selectedIndex!],
                fullScreen: false,
                onUpdate: _updateCarFromDetails,
              ),
            ),
        ],
      ),
    );
  }
}
