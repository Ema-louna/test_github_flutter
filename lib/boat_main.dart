import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart' show databaseFactoryFfiWeb;

import 'boat_listing.dart';
import 'boat_listing_dao.dart';
import 'app_database.dart';
import 'boat_form_page.dart';

class BoatMain extends StatefulWidget {
  const BoatMain({super.key});

  @override
  State<BoatMain> createState() => _BoatMainState();
}

class _BoatMainState extends State<BoatMain> {
  AppDatabase? _db;
  BoatListingDao? _dao;

  List<BoatListing> boats = [];
  bool _loading = true;
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _initDbAndLoad();
  }

  Future<void> _initDbAndLoad() async {
    try {
      if (kIsWeb) {
        sqflite.databaseFactory = databaseFactoryFfiWeb;
      }
      _db = await buildDb();
      _dao = _db!.boatListingDao;

      await _reloadBoats();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
      final bool isFrench =
          Localizations.localeOf(context).languageCode == 'fr';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isFrench ? 'Erreur de base de données: $e' : 'DB error: $e',
          ),
        ),
      );
    }
  }

  Future<void> _reloadBoats() async {
    if (_dao == null) return;
    final List<BoatListing> items = await _dao!.findAll();
    if (!mounted) return;
    setState(() {
      boats = items;
      _loading = false;
      if (_selectedIndex != null && _selectedIndex! >= boats.length) {
        _selectedIndex = boats.isEmpty ? null : 0;
      }
    });
  }

  Future<void> _openAddForm() async {
    final bool? changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const BoatFormPage(),
      ),
    );
    if (changed == true) {
      await _reloadBoats();
    }
  }

  Future<void> _openEditForm(BoatListing listing) async {
    final bool? changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BoatFormPage(existing: listing),
      ),
    );
    if (changed == true) {
      await _reloadBoats();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width >= 800;
    final bool isFrench =
        Localizations.localeOf(context).languageCode == 'fr';

    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            isFrench ? 'Bateaux à vendre' : 'Boats for Sale',
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 10),
              Text(
                isFrench
                    ? 'Chargement des annonces de bateaux...'
                    : 'Loading boat listings...',
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isFrench ? 'Bateaux à vendre' : 'Boats for Sale',
        ),
        actions: [
          IconButton(
            tooltip: isFrench ? 'Instructions' : 'Instructions',
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text(
                    isFrench
                        ? 'Instructions de l\'écran des bateaux'
                        : 'Boat screen instructions',
                  ),
                  content: Text(
                    isFrench
                        ? '1. Appuyez sur le bouton "+" pour ajouter un nouveau bateau.\n'
                        '2. Saisissez l\'année, la longueur, le type de propulsion, le prix et l\'adresse.\n'
                        '3. Les bateaux ajoutés apparaissent dans la liste.\n'
                        '4. Touchez un bateau dans la liste pour le modifier ou le supprimer.\n'
                        '5. Les annonces sont enregistrées dans une base de données et peuvent être copiées à partir de la précédente.'
                        : '1. Tap the "+" button to add a new boat listing.\n'
                        '2. Enter year built, length, power type, price, and address.\n'
                        '3. Added boats appear in the list.\n'
                        '4. Tap a boat in the list to update or delete it.\n'
                        '5. Listings are stored in a database and can copy from the previous listing.',
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: isWide ? _wideBody(isFrench) : _narrowBody(isFrench),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddForm,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _narrowBody(bool isFrench) {
    return _buildList(
      isFrench: isFrench,
      onTap: (int index) => _openEditForm(boats[index]),
      selectedIndex: null,
      showSelectionHighlight: false,
    );
  }

  Widget _wideBody(bool isFrench) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _buildList(
            isFrench: isFrench,
            onTap: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            selectedIndex: _selectedIndex,
            showSelectionHighlight: true,
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          flex: 3,
          child: _selectedIndex == null
              ? Center(
            child: Text(
              isFrench ? 'Sélectionnez un bateau' : 'Select a boat',
            ),
          )
              : _buildDetailPanel(
            boats[_selectedIndex!],
            isFrench,
          ),
        ),
      ],
    );
  }

  Widget _buildList({
    required bool isFrench,
    required void Function(int index) onTap,
    required int? selectedIndex,
    required bool showSelectionHighlight,
  }) {
    if (boats.isEmpty) {
      return Center(
        child: Text(
          isFrench
              ? 'Aucun bateau à vendre pour le moment.'
              : 'No boats for sale yet.',
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: boats.length,
      itemBuilder: (BuildContext context, int index) {
        final BoatListing b = boats[index];
        final bool selected = showSelectionHighlight &&
            selectedIndex != null &&
            selectedIndex == index;

        final String title = '${b.yearBuilt} - ${b.powerType}';
        final String subtitle = isFrench
            ? 'Longueur: ${b.lengthMeters} m, Prix: ${b.price}'
            : 'Length: ${b.lengthMeters} m, Price: ${b.price}';

        return Card(
          margin:
          const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: ListTile(
            title: Text(title),
            subtitle: Text(subtitle),
            selected: selected,
            onTap: () => onTap(index),
          ),
        );
      },
    );
  }

  Widget _buildDetailPanel(BoatListing b, bool isFrench) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isFrench ? 'Détails du bateau' : 'Boat Details',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          _detailRow(isFrench ? 'Année de construction' : 'Year built',
              b.yearBuilt.toString()),
          _detailRow(
              isFrench ? 'Longueur (mètres)' : 'Length (meters)',
              b.lengthMeters.toString()),
          _detailRow(
              isFrench ? 'Type de propulsion' : 'Power type', b.powerType),
          _detailRow(isFrench ? 'Prix' : 'Price', b.price.toString()),
          _detailRow(isFrench ? 'Adresse' : 'Address', b.address),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _openEditForm(b),
            child: Text(isFrench ? 'Modifier ce bateau' : 'Edit this boat'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
