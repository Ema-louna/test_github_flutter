import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'dart:convert';
import 'Purchase.dart';
import 'PurchaseDao.dart';
import 'PurchaseDatabase.dart';
import 'PurchaseOfferForm.dart';
import 'main.dart';
import 'purchase_localizations.dart';

/// Main screen displaying all purchase offers
class PurchaseOfferMain extends StatefulWidget {
  const PurchaseOfferMain({super.key});

  @override
  State<PurchaseOfferMain> createState() => _PurchaseOfferMainState();
}

class _PurchaseOfferMainState extends State<PurchaseOfferMain> {
  PurchaseDao? dao;
  List<Purchase> _offers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initDb();
  }

  /// Initialize database and load offers
  Future<void> _initDb() async {
    try {
      final database =
      await $FloorAppDatabase.databaseBuilder("purchases.db").build();
      dao = database.purchaseDao;
      await _loadOffers();
    } catch (e) {
      debugPrint("Database init error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Load all purchase offers
  Future<void> _loadOffers() async {
    if (dao == null) return;
    final items = await dao!.findAllPurchase();
    if (mounted) setState(() => _offers = items);
  }

  /// Refresh the list
  void refreshList() => _loadOffers();

  /// Add new purchase offer
  Future<void> _addPurchase() async {
    final EncryptedSharedPreferences prefs = EncryptedSharedPreferences();
    final lastJson = await prefs.getString("last_purchase");
    Purchase? lastPurchase;
    if (lastJson != null) {
      final map = Map<String, dynamic>.from(
          Map<String, dynamic>.from(await Future.value(Map<String, dynamic>.from(jsonDecode(lastJson)))));
      lastPurchase = Purchase(
        map['id'],
        map['customerID'],
        map['vehicleId'],
        map['price'],
        map['dateOfOffer'],
        map['status'],
      );
    }

    if (lastPurchase != null) {
      // Ask user to copy or blank
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("New Purchase Offer"),
          content: const Text(
              "Do you want to copy the previous customer data or start blank?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        PurchaseOfferForm(dao: dao!, onSaved: refreshList),
                  ),
                );
              },
              child: const Text("Blank"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PurchaseOfferForm(
                      dao: dao!,
                      onSaved: refreshList,
                      initialData: lastPurchase,
                    ),
                  ),
                );
              },
              child: const Text("Copy"),
            ),
          ],
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PurchaseOfferForm(dao: dao!, onSaved: refreshList),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)?.translate;

    return Scaffold(
      appBar: AppBar(
        title: Text(t?.call("title") ?? "Purchase Offers"),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title:
                  Text(t?.call("instructions_title") ?? "Instructions"),
                  content: Text(t?.call("instructions_body") ??
                      "- Fill in purchase fields\n- Tap a purchase for details\n- Switch language with menu"),
                  actions: [
                    TextButton(
                      child: Text(t?.call("ok") ?? "OK"),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.language),
            onSelected: (value) {
              final newLocale = value == "US"
                  ? const Locale("en", "US")
                  : const Locale("en", "GB");
              MyApp.setLocale(context, newLocale);
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: "US", child: Text("English (US)")),
              PopupMenuItem(value: "UK", child: Text("English (UK)")),
            ],
          ),
        ],
      ),
      floatingActionButton: dao == null
          ? null
          : FloatingActionButton(
        onPressed: _addPurchase,
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _offers.isEmpty
          ? Center(
          child: Text(t?.call("no_offers") ?? "No offers found"))
          : ListView.builder(
        itemCount: _offers.length,
        itemBuilder: (context, index) {
          final offer = _offers[index];
          return Card(
            child: ListTile(
              title: Text(
                  "${t?.call("customer") ?? "Customer"}: ${offer.customerID}"),
              subtitle: Text(
                  "${t?.call("vehicle") ?? "Vehicle"}: ${offer.vehicleId} — \$${offer.price}"),
              trailing: Text(offer.status),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PurchaseOfferForm(
                      dao: dao!,
                      offer: offer,
                      onSaved: refreshList,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
