import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'Purchase.dart';
import 'PurchaseDao.dart';

class PurchaseOfferForm extends StatefulWidget {
  final PurchaseDao dao;
  final Purchase? offer; // null = create new
  final VoidCallback onSaved;

  const PurchaseOfferForm({
    super.key,
    required this.dao,
    required this.onSaved,
    this.offer,
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

  final EncryptedSharedPreferences _prefs = EncryptedSharedPreferences();

  bool get isEditing => widget.offer != null;

  @override
  void initState() {
    super.initState();
    _loadSavedCustomerId();
    if (isEditing) _loadOfferForEdit();
  }

  Future<void> _loadSavedCustomerId() async {
    String lastId = await _prefs.getString("last_customer_id") ?? "";
    if (!isEditing) {
      _customerIDController.text = lastId;
    }
  }

  void _loadOfferForEdit() {
    final o = widget.offer!;
    _customerIDController.text = o.customerID;
    _vehicleIDController.text = o.vehicleId;
    _priceController.text = o.price;
    _dateController.text = o.dateOfOffer;
    _status = o.status;
  }

  @override
  void dispose() {
    _customerIDController.dispose();
    _vehicleIDController.dispose();
    _priceController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  /// VALIDATE & SAVE
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    // Save customer ID for next time
    await _prefs.setString("last_customer_id", _customerIDController.text);

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
        const SnackBar(content: Text("Offer updated successfully")),
      );
    } else {
      await widget.dao.insertPurchase(purchase);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Offer added successfully")),
      );
    }

    widget.onSaved();
    Navigator.pop(context);
  }

  /// DELETE WITH CONFIRMATION
  void _confirmDelete() {
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
                const SnackBar(content: Text("Offer deleted")),
              );

              widget.onSaved();
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // close form page
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
        Text(isEditing ? "Edit Purchase Offer" : "Add Purchase Offer"),
      ),
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
                  DropdownMenuItem(
                    value: "accepted",
                    child: Text("Accepted"),
                  ),
                  DropdownMenuItem(
                    value: "rejected",
                    child: Text("Rejected"),
                  ),
                ],
                onChanged: (v) => setState(() => _status = v!),
                decoration: const InputDecoration(
                  labelText: "Status",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 30),

              // Submit / Update / Delete buttons
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
                  style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text("Delete Offer"),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  /// Helper input field builder
  Widget _input(String label, TextEditingController controller,
      {TextInputType keyboard = TextInputType.text}) {
    return TextFormField(
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
}
