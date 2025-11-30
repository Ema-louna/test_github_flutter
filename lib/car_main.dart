import 'package:flutter/material.dart';
import 'Car.dart';
import 'CarDAO.dart';
import 'CarDatabase.dart';
import 'car_detail_page.dart';
import 'app_localizations.dart';
import 'main.dart';

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

  final TextEditingController _newCarName = TextEditingController();

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
        SnackBar(content: Text(AppLocalizations.of(context)!.translate("car_deleted"))),
      );
    } else {
      await _dao!.updateCar(updatedCar);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "${AppLocalizations.of(context)!.translate("updated")}: ${updatedCar.name}",
          ),
        ),
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
        title: Text(AppLocalizations.of(context)!.translate("cars")),

        actions: [
          // 📘 Instructions button
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: "Instructions",
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text("Instructions"),
                  content: const Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("• Add a car using the text field at the top."),
                      Text("• Tap a car to view or edit its details."),
                      Text("• On wide screens, details appear beside the list."),
                      Text("• Use Delete to remove a car."),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text("OK"),
                    ),
                  ],
                ),
              );
            },
          ),

          // 🌐 Language switch button
          IconButton(
            icon: const Icon(Icons.language),
            tooltip: "Change Language",
            onPressed: () {
              final current = Localizations.localeOf(context).languageCode;
              if (current == 'en') {
                MyApp.setLocale(context, const Locale('fr'));
              } else {
                MyApp.setLocale(context, const Locale('en'));
              }
            },
          ),
        ],
      ),

      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // ADD CAR BAR
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _newCarName,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.translate("add_car_name"),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      ElevatedButton(
                        onPressed: () async {
                          if (_newCarName.text.trim().isEmpty) return;

                          final newCar = Car(
                            Car.ID++,
                            _newCarName.text.trim(),
                            "",
                            "",
                            "",
                            "",
                          );

                          await _dao!.insertCar(newCar);
                          _newCarName.clear();
                          _loadCars();
                        },
                        child: Text(AppLocalizations.of(context)!.translate("add")),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // LIST OF CARS
                  Expanded(
                    child: ListView.builder(
                      itemCount: _cars.length,
                      itemBuilder: (context, index) {
                        final car = _cars[index];
                        return ListTile(
                          title: Text(car.name),
                          subtitle: Text(
                            car.model.isEmpty
                                ? AppLocalizations.of(context)!.translate("no_model")
                                : car.model,
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

          if (isWide)
            Expanded(
              child: _selectedIndex == null
                  ? Center(
                child: Text(
                  AppLocalizations.of(context)!.translate("select_car"),
                  style: const TextStyle(fontSize: 18),
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
