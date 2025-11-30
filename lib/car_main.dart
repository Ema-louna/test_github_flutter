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

  // Load highest ID from DB to avoid UNIQUE constraint crash
  Future<void> _initializeCarID() async {
    final cars = await _dao!.getAllCars();
    if (cars.isNotEmpty) {
      int maxId = cars.map((c) => c.id).reduce((a, b) => a > b ? a : b);
      Car.ID = maxId + 1;
    } else {
      Car.ID = 1;
    }
  }

  Future<void> _initFloorDb() async {
    final db = await $FloorCarDatabase.databaseBuilder("cars.db").build();
    _database = db;
    _dao = db.carDao;

    await _initializeCarID();
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
        SnackBar(content: Text(AppLocalizations.of(context)!.translate("car_deleted") ?? "Deleted")),
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
    final tr = AppLocalizations.of(context)!.translate;
    final isWide = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(tr("cars")),

        actions: [
          // 📘 Instructions Button (full text in EN + FR)
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: "Instructions",
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text("Instructions / Instructions"),
                  content: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          "ENGLISH:\n\n"
                              "• Use the text field at the top to add a new car to the list.\n"
                              "• Tap a car to view its details and modify name, model, year, color, or description.\n"
                              "• On larger screens (tablet/desktop), the details will appear on the right side.\n"
                              "• Use the Delete button in the detail view to remove a car from the list.\n"
                              "• Your data is saved in a local database and will reappear when reopening the app.",
                          style: TextStyle(fontSize: 14),
                        ),
                        SizedBox(height: 20),
                        Text(
                          "FRANÇAIS:\n\n"
                              "• Utilisez le champ en haut pour ajouter une nouvelle voiture à la liste.\n"
                              "• Appuyez sur une voiture pour voir ses détails et modifier le nom, le modèle, l'année, la couleur ou la description.\n"
                              "• Sur les écrans plus larges (tablette/ordinateur), les détails apparaissent à droite.\n"
                              "• Utilisez le bouton Supprimer dans la page des détails pour retirer une voiture.\n"
                              "• Vos données sont sauvegardées dans une base locale et réapparaissent lorsque l'application est rouverte.",
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
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

          // 🌐 Language Switch Button
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
                  // ADD CAR FIELD + BUTTON
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _newCarName,
                          decoration: InputDecoration(
                            labelText: tr("add_car_name"),
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
                        child: Text(tr("add")),
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
                            car.model.isEmpty ? tr("no_model") : car.model,
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

          // RIGHT-SIDE PANEL
          if (isWide)
            Expanded(
              child: _selectedIndex == null
                  ? Center(
                child: Text(
                  tr("select_car"),
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
