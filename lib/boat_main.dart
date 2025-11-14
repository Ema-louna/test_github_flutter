import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart' show databaseFactoryFfiWeb;

import 'boat_item.dart';
import 'boat_item_dao.dart';
import 'app_database.dart';
import 'boat_detail_page.dart';
import 'boat_lastentryprefs.dart';

class BoatMain extends StatefulWidget {
  const BoatMain({super.key});

  @override
  State<BoatMain> createState() => _BoatMainState();
}

class _BoatMainState extends State<BoatMain> {
  AppDatabase? _db;
  BoatItemDao? _dao;

  List<BoatItem> boats = [];
  final TextEditingController _controller = TextEditingController();
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
      _dao = _db!.boatItemDao;

      final List<BoatItem> items = await _dao!.findAll();
      final String? last = await BoatLastEntryPrefs.loadLastBoatName();

      if (!mounted) return;
      setState(() {
        boats = items;
        _loading = false;
      });

      if (last != null && last.isNotEmpty && mounted) {
        final bool isFrench =
            Localizations.localeOf(context).languageCode == 'fr';

        final bool ok = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(
              isFrench ? 'Pré-remplir la dernière saisie ?' : 'Prefill last entry?',
            ),
            content: Text(
              isFrench
                  ? 'Utiliser le dernier nom de bateau saisi :\n\n"$last"'
                  : 'Use the last typed boat name:\n\n"$last"',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(isFrench ? 'Non' : 'No'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(isFrench ? 'Oui' : 'Yes'),
              ),
            ],
          ),
        ) ??
            false;

        if (ok && mounted) {
          _controller.text = last;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isFrench
                    ? 'Dernier nom de bateau pré-rempli'
                    : 'Prefilled last boat name',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
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

  Future<void> _addBoat() async {
    final String text = _controller.text.trim();
    final bool isFrench =
        Localizations.localeOf(context).languageCode == 'fr';

    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isFrench
                ? 'Veuillez entrer un nom de bateau.'
                : 'Please enter a boat name!',
          ),
        ),
      );
      return;
    }
    if (_dao == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isFrench
                ? 'La base de données n\'est pas encore prête.'
                : 'Database not ready yet!',
          ),
        ),
      );
      return;
    }

    await BoatLastEntryPrefs.saveLastBoatName(text);

    await _dao!.insertItem(BoatItem(name: text));
    _controller.clear();

    final List<BoatItem> items = await _dao!.findAll();
    if (!mounted) return;
    setState(() {
      boats = items;
      if (_selectedIndex != null && _selectedIndex! >= boats.length) {
        _selectedIndex = boats.isEmpty ? null : 0;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isFrench
              ? 'Bateau ajouté. Total: ${boats.length}'
              : 'Boat added! Total: ${boats.length}',
        ),
      ),
    );
  }

  Future<void> _deleteBoatWithConfirm(int index) async {
    final BoatItem item = boats[index];
    final bool isFrench =
        Localizations.localeOf(context).languageCode == 'fr';

    final bool ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          isFrench ? 'Supprimer le bateau ?' : 'Delete boat?',
        ),
        content: Text(
          isFrench
              ? 'Cela va supprimer "${item.name}".'
              : 'This will remove "${item.name}".',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(isFrench ? 'Annuler' : 'Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(isFrench ? 'Supprimer' : 'Delete'),
          ),
        ],
      ),
    ) ??
        false;

    if (!ok) return;

    if (_dao == null) return;
    if (item.id != null) {
      await _dao!.deleteById(item.id!);
    }
    final List<BoatItem> items = await _dao!.findAll();
    if (!mounted) return;
    setState(() {
      boats = items;
      if (_selectedIndex == index) {
        _selectedIndex = null;
      } else if (_selectedIndex != null && index < _selectedIndex!) {
        _selectedIndex = _selectedIndex! - 1;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isFrench
              ? 'Bateau supprimé: "${item.name}"'
              : 'Deleted "${item.name}"',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width >= 600;
    final bool isFrench =
        Localizations.localeOf(context).languageCode == 'fr';

    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(isFrench ? 'Bateaux à vendre' : 'Boats for Sale'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 10),
              Text(
                isFrench
                    ? 'Chargement de la base de données...'
                    : 'Loading Database...',
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isFrench ? 'Bateaux à vendre' : 'Boats for Sale'),
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
                        ? '1. Saisissez un nom de bateau dans le champ texte.\n'
                        '2. Appuyez sur "Ajouter un bateau" pour l\'ajouter à la liste.\n'
                        '3. Sur un téléphone: touchez un bateau pour ouvrir l\'écran de détails.\n'
                        '4. Sur une tablette ou un bureau: touchez un bateau pour voir les détails à côté de la liste.\n'
                        '5. Utilisez l\'icône de suppression pour enlever un bateau.\n'
                        '6. L\'application mémorise votre dernier nom de bateau saisi de manière chiffrée pour le prochain lancement.'
                        : '1. Type a boat name in the text field.\n'
                        '2. Press "Add Boat" to insert the boat into the list.\n'
                        '3. On a phone: tap a boat to open the details screen.\n'
                        '4. On a tablet/desktop: tap a boat to see details beside the list.\n'
                        '5. Use the delete icon to remove a boat.\n'
                        '6. The app remembers your last typed boat name securely for the next launch.',
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: isWide ? _wideBody(isFrench) : _narrowBody(isFrench),
    );
  }

  Widget _narrowBody(bool isFrench) {
    return Column(
      children: [
        _topForm(isFrench),
        Expanded(
          child: _listBuilder(
            isFrench: isFrench,
            onTap: (int i) {
              final BoatItem b = boats[i];
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BoatDetailPage(boat: b),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _wideBody(bool isFrench) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              children: [
                _topForm(isFrench),
                Expanded(
                  child: _listBuilder(
                    isFrench: isFrench,
                    selectedIndex: _selectedIndex,
                    onTap: (int i) => setState(() => _selectedIndex = i),
                  ),
                ),
              ],
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
                : Padding(
              padding: const EdgeInsets.all(16),
              child: _SideDetailPanel(
                boat: boats[_selectedIndex!],
                isFrench: isFrench,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _topForm(bool isFrench) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: _addBoat,
            child: Text(isFrench ? 'Ajouter un bateau' : 'Add Boat'),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: isFrench
                    ? 'Entrez le nom du bateau'
                    : 'Enter Boat Name',
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (_) => _addBoat(),
              onChanged: (String s) {
                BoatLastEntryPrefs.saveLastBoatName(s.trim());
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _listBuilder({
    int? selectedIndex,
    required void Function(int) onTap,
    required bool isFrench,
  }) {
    if (boats.isEmpty) {
      return Center(
        child: Text(
          isFrench
              ? 'Aucun bateau pour le moment. Ajoutez-en un pour commencer.'
              : 'No boats yet. Add one to get started!',
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }
    return ListView.builder(
      itemCount: boats.length,
      itemBuilder: (BuildContext context, int index) {
        final BoatItem item = boats[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: ListTile(
            title: Text(
              item.name,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            subtitle: Text(
              isFrench ? 'Ligne ${index + 1}' : 'Row ${index + 1}',
            ),
            selected: selectedIndex == index,
            onTap: () => onTap(index),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _deleteBoatWithConfirm(index),
            ),
          ),
        );
      },
    );
  }
}

class _SideDetailPanel extends StatelessWidget {
  final BoatItem boat;
  final bool isFrench;

  const _SideDetailPanel({
    required this.boat,
    required this.isFrench,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isFrench ? 'Détails du bateau' : 'Boat Details',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        _row(isFrench ? 'ID' : 'ID', boat.id?.toString() ?? '-'),
        _row(isFrench ? 'Nom' : 'Name', boat.name),
      ],
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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
          const SizedBox(height: 4),
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
