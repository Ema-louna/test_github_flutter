import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'Purchase.dart';
import 'PurchaseDao.dart';

/// Form to add or edit a purchase offer
class PurchaseOfferForm extends StatefulWidget {
  final PurchaseDao dao;
  final VoidCallback onSaved;
  final Purchase? offer;
  final Purchase? initialData;

  const PurchaseOfferForm({
    super.key,
    required this.dao,
    required this.onSaved,
    this.offer,
    this.initialData,
  });

  @override
  State<PurchaseOfferForm> createState() => _PurchaseOfferFormState();
}

class _PurchaseOfferFormState extends State<PurchaseOfferForm> {
  final _formKey = GlobalKey<FormState>();
  final _customerIDController = TextEditingController();
  final _vehicleIDController = TextEditingController();
  final _priceController = TextEditingController();
  final _dateController = TextEditingController();
  String _status = "accepted";

  bool get isEditing => widget.offer != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _loadPurchase(widget.offer!);
    } else if (widget.initialData != null) {
      _loadPurchase(widget.initialData!);
    }
  }

  void _loadPurchase(Purchase p) {
    _customerIDController.text = p.customerID;
    _vehicleIDController.text = p.vehicleId;
    _priceController.text = p.price;
    _dateController.text = p.dateOfOffer;
    _status = p.status;
  }

  @override
  void dispose() {
    _customerIDController.dispose();
    _vehicleIDController.dispose();
    _priceController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  /// Save or update the purchase offer
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final purchase = Purchase(
      isEditing ? widget.offer!.id : Purchase.ID++,
      _customerIDController.text,
      _vehicleIDController.text,
      _priceController.text,
      _dateController.text,
      _status,
    );

    if (isEditing) {
      await widget.dao.updatePurchase(purchase);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Offer updated successfully")));
    } else {
      await widget.dao.insertPurchase(purchase);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Offer added successfully")));
    }

    // Save to EncryptedSharedPreferences for future copy
    final prefs = EncryptedSharedPreferences();
    await prefs.setString("last_purchase", jsonEncode({
      "id": purchase.id,
      "customerID": purchase.customerID,
      "vehicleId": purchase.vehicleId,
      "price": purchase.price,
      "dateOfOffer": purchase.dateOfOffer,
      "status": purchase.status,
    }));

    widget.onSaved();
    Navigator.pop(context);
  }

  void _confirmDelete() {
    if (!isEditing) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Offer"),
        content: const Text("Are you sure you want to delete this offer?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              await widget.dao.deletePurchase(widget.offer!);
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Offer deleted")));
              widget.onSaved();
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title:
          Text(isEditing ? "Edit Purchase Offer" : "Add Purchase Offer")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _input("Customer ID", _customerIDController),
              const SizedBox(height: 10),
              _input("Vehicle / Boat / Car ID", _vehicleIDController),
              const SizedBox(height: 10),
              _input("Price", _priceController, keyboard: TextInputType.number),
              const SizedBox(height: 10),
              _input("Date (YYYY-MM-DD)", _dateController),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _status,
                items: const [
                  DropdownMenuItem(value: "accepted", child: Text("Accepted")),
                  DropdownMenuItem(value: "rejected", child: Text("Rejected")),
                ],
                onChanged: (v) => setState(() => _status = v!),
                decoration: const InputDecoration(
                  labelText: "Status",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30),
              if (!isEditing)
                ElevatedButton(
                  onPressed: _save,
                  child: const Text("Submit Offer"),
                )
              else ...[
                ElevatedButton(
                  onPressed: _save,
                  child: const Text("Update Offer"),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _confirmDelete,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text("Delete Offer"),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _input(String label, TextEditingController controller,
      {TextInputType keyboard = TextInputType.text}) =>
      TextFormField(
        controller: controller,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (v) =>
        v == null || v.trim().isEmpty ? "Required field" : null,
      );
}
