import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart' show databaseFactoryFfiWeb;

import 'boat_item.dart';
import 'boat_item_dao.dart';
import 'app_database.dart';

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

      final items = await _dao!.findAll();
      if (!mounted) return;
      setState(() {
        boats = items;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('DB error: $e')));
    }
  }

  Future<void> _addBoat() async {
    final text = _controller.text.trim();
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

    await _dao!.insertItem(BoatItem(name: text));
    _controller.clear();

    final items = await _dao!.findAll();
    if (!mounted) return;
    setState(() => boats = items);

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Boat added! Total: ${boats.length}')));
  }

  Future<void> _deleteBoat(int index) async {
    if (_dao == null) return;
    final item = boats[index];
    if (item.id != null) {
      await _dao!.deleteById(item.id!);
    }
    final items = await _dao!.findAll();
    if (!mounted) return;
    setState(() => boats = items);

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Deleted "${item.name}"')));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Boats for Sale')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [CircularProgressIndicator(), SizedBox(height: 10), Text('Loading Database...')],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Boats for Sale')),
      body: ListPage(),
    );
  }

  Widget ListPage() {
    return Column(
      children: [
        Padding(
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
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: boats.isEmpty
              ? const Center(
            child: Text('No boats yet. Add one to get started!',
                style: TextStyle(fontSize: 16, color: Colors.grey)),
          )
              : ListView.builder(
            itemCount: boats.length,
            itemBuilder: (context, index) {
              final item = boats[index];
              return GestureDetector(
                onTap: () => _deleteBoat(index),
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Row ${index + 1}'),
                      Text(item.name),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
