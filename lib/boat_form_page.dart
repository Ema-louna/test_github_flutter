import 'package:flutter/material.dart';
import 'boat_listing.dart';
import 'app_database.dart';
import 'boat_lastlisting_prefs.dart';

class BoatFormPage extends StatefulWidget {
  final BoatListing? existing;

  const BoatFormPage({super.key, this.existing});

  @override
  State<BoatFormPage> createState() => _BoatFormPageState();
}

class _BoatFormPageState extends State<BoatFormPage> {
  late TextEditingController _yearController;
  late TextEditingController _lengthController;
  late TextEditingController _priceController;
  late TextEditingController _addressController;
  String _powerType = 'Sail';

  bool _isSaving = false;
  bool _initializedFromPrefs = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();

    _yearController = TextEditingController();
    _lengthController = TextEditingController();
    _priceController = TextEditingController();
    _addressController = TextEditingController();

    if (_isEdit) {
      final BoatListing b = widget.existing!;
      _yearController.text = b.yearBuilt.toString();
      _lengthController.text = b.lengthMeters.toString();
      _priceController.text = b.price.toStringAsFixed(2);
      _addressController.text = b.address;
      _powerType = b.powerType;
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _maybeOfferCopyFromPrevious();
      });
    }
  }

  Future<void> _maybeOfferCopyFromPrevious() async {
    if (_initializedFromPrefs) return;
    _initializedFromPrefs = true;

    final Map<String, dynamic>? last =
    await BoatLastListingPrefs.loadLastListing();
    if (!mounted) return;
    if (last == null) return;

    final bool isFrench =
        Localizations.localeOf(context).languageCode == 'fr';

    final bool copy = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          isFrench
              ? 'Copier la précédente annonce ?'
              : 'Copy previous listing?',
        ),
        content: Text(
          isFrench
              ? 'Voulez-vous copier les informations du précédent bateau ?'
              : 'Do you want to copy the fields from the previous boat?',
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

    if (copy && mounted) {
      _yearController.text = last['yearBuilt'].toString();
      _lengthController.text = last['lengthMeters'].toString();
      _powerType = (last['powerType'] ?? 'Sail') as String;
      _priceController.text = last['price'].toString();
      _addressController.text = last['address']?.toString() ?? '';
      setState(() {});
    }
  }

  Future<void> _saveOrUpdate() async {
    if (_isSaving) return;
    setState(() {
      _isSaving = true;
    });

    final bool isFrench =
        Localizations.localeOf(context).languageCode == 'fr';

    try {
      if (_yearController.text.trim().isEmpty ||
          _lengthController.text.trim().isEmpty ||
          _priceController.text.trim().isEmpty ||
          _addressController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isFrench
                  ? 'Tous les champs doivent être remplis.'
                  : 'All fields must be filled in.',
            ),
          ),
        );
        setState(() {
          _isSaving = false;
        });
        return;
      }

      final int? year = int.tryParse(_yearController.text.trim());
      final double? length =
      double.tryParse(_lengthController.text.trim());
      final double? price =
      double.tryParse(_priceController.text.trim());

      if (year == null || year < 1900) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isFrench
                  ? 'Entrez une année valide (>= 1900).'
                  : 'Enter a valid year (>= 1900).',
            ),
          ),
        );
        setState(() {
          _isSaving = false;
        });
        return;
      }
      if (length == null || length <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isFrench
                  ? 'Entrez une longueur valide (> 0).'
                  : 'Enter a valid length (> 0).',
            ),
          ),
        );
        setState(() {
          _isSaving = false;
        });
        return;
      }
      if (price == null || price < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isFrench
                  ? 'Entrez un prix valide (>= 0).'
                  : 'Enter a valid price (>= 0).',
            ),
          ),
        );
        setState(() {
          _isSaving = false;
        });
        return;
      }

      final String address = _addressController.text.trim();

      final db = await buildDb();
      final dao = db.boatListingDao;

      if (_isEdit) {
        final BoatListing updated = widget.existing!.copyWith(
          yearBuilt: year,
          lengthMeters: length,
          powerType: _powerType,
          price: price,
          address: address,
        );
        await dao.updateListing(updated);
      } else {
        final BoatListing newListing = BoatListing(
          yearBuilt: year,
          lengthMeters: length,
          powerType: _powerType,
          price: price,
          address: address,
        );
        await dao.insertListing(newListing);
      }

      await BoatLastListingPrefs.saveLastListing(
        yearBuilt: year,
        lengthMeters: length,
        powerType: _powerType,
        price: price,
        address: address,
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _deleteListing() async {
    if (!_isEdit) return;

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
              ? 'Cela va supprimer cette annonce de bateau.'
              : 'This will remove this boat listing.',
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

    final db = await buildDb();
    final dao = db.boatListingDao;
    await dao.deleteListing(widget.existing!);

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final bool isFrench =
        Localizations.localeOf(context).languageCode == 'fr';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEdit
              ? (isFrench ? 'Modifier le bateau' : 'Edit Boat')
              : (isFrench ? 'Ajouter un bateau' : 'Add Boat'),
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
                        ? 'Instructions du formulaire de bateau'
                        : 'Boat form instructions',
                  ),
                  content: Text(
                    isFrench
                        ? 'Remplissez tous les champs pour décrire le bateau.\n'
                        'Utilisez le bouton Enregistrer pour ajouter ou mettre à jour.\n'
                        'Utilisez le bouton Supprimer pour enlever l\'annonce.'
                        : 'Fill in all fields to describe the boat.\n'
                        'Use the Save button to add or update.\n'
                        'Use the Delete button to remove the listing.',
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _yearController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText:
                  isFrench ? 'Année de construction' : 'Year built',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _lengthController,
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: isFrench
                      ? 'Longueur (mètres)'
                      : 'Length (meters)',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _powerType,
                decoration: InputDecoration(
                  labelText:
                  isFrench ? 'Type de propulsion' : 'Power type',
                  border: const OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'Sail',
                    child: Text(isFrench ? 'Voile' : 'Sail'),
                  ),
                  DropdownMenuItem(
                    value: 'Motor',
                    child: Text(isFrench ? 'Moteur' : 'Motor'),
                  ),
                ],
                onChanged: (String? value) {
                  if (value == null) return;
                  setState(() {
                    _powerType = value;
                  });
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _priceController,
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: isFrench ? 'Prix' : 'Price',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: isFrench ? 'Adresse' : 'Address',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveOrUpdate,
                      child: Text(
                        _isEdit
                            ? (isFrench ? 'Mettre à jour' : 'Update')
                            : (isFrench ? 'Enregistrer' : 'Save'),
                      ),
                    ),
                  ),
                  if (_isEdit) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                        ),
                        onPressed: _isSaving ? null : _deleteListing,
                        child: Text(
                          isFrench ? 'Supprimer' : 'Delete',
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
