/**
 * -------------------------------------------------------------
 *  CST2335 – Graphical Interface Programming
 *  Final Project – Cars Module
 *
 *  Student: Emanuelle Marchant
 *  Student ID: 041173314
 *  Due Date: November 30, 2025
 *
 *  File: car_main.dart
 *  Purpose: This file implements the Cars section of the
 *           final project.
 *  Each function below is documented using Dartdoc style.
 * -------------------------------------------------------------
 */

import 'package:flutter/material.dart';
import 'Car.dart';
import 'CarDAO.dart';
import 'CarDatabase.dart';
import 'car_detail_page.dart';
import 'app_localizations.dart';
import 'main.dart';

/// Main page for managing cars.
/// Displays a ListView of cars, a text field to add new cars,
/// and a details panel (or a separate page on smaller screens).
class CarsMain extends StatefulWidget {
  const CarsMain({super.key});

  @override
  State<CarsMain> createState() => _CarsMainState();
}

class _CarsMainState extends State<CarsMain> {
  /// Reference to the Floor database.
  CarDatabase? _database;

  /// Car Data Access Object.
  CarDAO? _dao;

  /// List of all cars loaded from the database.
  List<Car> _cars = [];

  /// Selected index for wide-screen layouts.
  int? _selectedIndex;

  /// Controller for the "Add new car" text field.
  final TextEditingController _newCarName = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initFloorDb();
  }

  /// Initializes the Floor database and loads saved data.
  Future<void> _initFloorDb() async {
    final db = await $FloorCarDatabase.databaseBuilder("cars.db").build();
    _database = db;
    _dao = db.carDao;

    await _initializeCarID();
    _loadCars();
  }

  /// Ensures the next inserted car has a unique ID by reading the largest
  /// existing ID in the database.
  Future<void> _initializeCarID() async {
    final cars = await _dao!.getAllCars();
    if (cars.isNotEmpty) {
      int maxId = cars.map((c) => c.id).reduce((a, b) => a > b ? a : b);
      Car.ID = maxId + 1;
    } else {
      Car.ID = 1;
    }
  }

  /// Reloads all cars from the database and updates the UI.
  Future<void> _loadCars() async {
    if (_dao == null) return;
    final cars = await _dao!.getAllCars();
    setState(() => _cars = cars);
  }

  /// Opens the detail page or displays the right-side panel depending on screen width.
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

  /// Called when updating or deleting a car in the detail page.
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

        /// Action buttons on the AppBar
        actions: [
          /// Instructions Dialog (EN + FR paragraph block)
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
                      children: const [
                        /// English section
                        Text(
                          "ENGLISH:\n\n"
                              "• Use the text field at the top to add a new car to the list.\n"
                              "• Tap a car to view its details and modify its information.\n"
                              "• On larger screens, details appear on the right.\n"
                              "• Press Delete in the detail page to remove a car.\n"
                              "• All data is saved locally and restored automatically.",
                        ),
                        SizedBox(height: 16),

                        /// French section
                        Text(
                          "FRANÇAIS:\n\n"
                              "• Utilisez le champ en haut pour ajouter une nouvelle voiture.\n"
                              "• Appuyez sur une voiture pour voir et modifier ses détails.\n"
                              "• Sur les grands écrans, les détails apparaissent à droite.\n"
                              "• Appuyez sur Supprimer pour retirer une voiture.\n"
                              "• Toutes les données sont sauvegardées localement.",
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

          /// Manual language switch (English <-> French)
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
          /// Left-side list + add bar
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  /// Add new car input row
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

                  /// Cars ListView
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

          /// Right-side detail panel (tablets/desktops only)
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
