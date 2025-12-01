import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'Purchase.dart';
import 'PurchaseDao.dart';
import 'PurchaseDatabase.dart';
import 'PurchaseOfferForm.dart';



class PurchaseOfferMain extends StatefulWidget {
  const PurchaseOfferMain({super.key});

  @override
  State<PurchaseOfferMain> createState() => _PurchaseOfferMainState();
}

class _PurchaseOfferMainState extends State<PurchaseOfferMain> {
  late PurchaseDao dao;
  List<Purchase> _offers = [];

  final EncryptedSharedPreferences _prefs = EncryptedSharedPreferences();

  String? lastTypedCustomerId;

  @override
  void initState() {
    super.initState();
    _initDb();
    _loadCustomerId();
  }

  Future<void> _initDb() async {
    final database =
    await $FloorAppDatabase.databaseBuilder("purchases.db").build();

    dao = database.purchaseDao;

    _loadOffers();
  }

  Future<void> _loadOffers() async {
    final items = await dao.findAllPurchase();
    setState(() {
      _offers = items;
    });
  }

  Future<void> _loadCustomerId() async {
    lastTypedCustomerId =
        await _prefs.getString("last_customer_id") ?? "";
  }

  /// Called after an offer is added, updated, or deleted
  void refreshList() => _loadOffers();

  bool get isTabletOrDesktop =>
      MediaQuery.of(context).size.width >= 700;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Purchase Offers")),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PurchaseOfferForm(
                dao: dao,
                onSaved: refreshList,
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: isTabletOrDesktop
          ? Row(
        children: [
          Expanded(child: _buildList()),
          const VerticalDivider(width: 1),
          Expanded(
            child: Center(
              child: Text(
                "Select an offer to view details",
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ),
          )
        ],
      )
          : _buildList(),
    );
  }

  Widget _buildList() {
    if (_offers.isEmpty) {
      return const Center(
        child: Text("No purchase offers yet."),
      );
    }

    return ListView.builder(
      itemCount: _offers.length,
      itemBuilder: (context, index) {
        final offer = _offers[index];

        return Card(
          child: ListTile(
            title: Text("Customer: ${offer.customerID}"),
            subtitle: Text("Vehicle: ${offer.vehicleId} — \$${offer.price}"),
            trailing: Text(offer.status),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PurchaseOfferForm(
                    dao: dao,
                    offer: offer,
                    onSaved: refreshList,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
