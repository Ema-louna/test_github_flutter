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
        final bool ok = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Prefill last entry?'),
            content: Text('Use the last typed boat name:\n\n"$last"'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('No'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Yes'),
              ),
            ],
          ),
        ) ??
            false;

        if (ok && mounted) {
          _controller.text = last;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Prefilled last boat name')),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('DB error: $e')));
    }
  }

  Future<void> _addBoat() async {
    final String text = _controller.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please enter a boat name!')));
      return;
    }
    if (_dao == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Database not ready yet!')));
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

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Boat added! Total: ${boats.length}')));
  }

  Future<void> _deleteBoatWithConfirm(int index) async {
    final BoatItem item = boats[index];
    final bool ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete boat?'),
        content: Text('This will remove "${item.name}".'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
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

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Deleted "${item.name}"')));
  }

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width >= 600;

    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Boats for Sale')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 10),
              Text('Loading Database...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Boats for Sale'),
        actions: [
          IconButton(
            tooltip: 'Help',
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => const AlertDialog(
                  title: Text('How to use'),
                  content: Text(
                    'Type a boat name then press "Add Boat" to insert it.\n\n'
                        'Tap an item to view details (phone = full screen; tablet/desktop = side panel).\n'
                        'Your last typed boat name can be remembered for next time.',
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: isWide ? _wideBody() : _narrowBody(),
    );
  }

  Widget _narrowBody() {
    return Column(
      children: [
        _topForm(),
        Expanded(
          child: _listBuilder(
            onTap: (int i) {
              final BoatItem b = boats[i];
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => BoatDetailPage(boat: b)),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _wideBody() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              children: [
                _topForm(),
                Expanded(
                  child: _listBuilder(
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
                ? const Center(child: Text('Select a boat'))
                : Padding(
              padding: const EdgeInsets.all(16),
              child: _SideDetailPanel(boat: boats[_selectedIndex!]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _topForm() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(onPressed: _addBoat, child: const Text('Add Boat')),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Enter Boat Name',
                border: OutlineInputBorder(),
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
  }) {
    if (boats.isEmpty) {
      return const Center(
        child: Text(
          'No boats yet. Add one to get started!',
          style: TextStyle(fontSize: 16, color: Colors.grey),
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
            title: Text(item.name, style: Theme.of(context).textTheme.bodyLarge),
            subtitle: Text('Row ${index + 1}'),
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
  const _SideDetailPanel({required this.boat});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Boat Details', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        _row('ID', boat.id?.toString() ?? '-'),
        _row('Name', boat.name),
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
