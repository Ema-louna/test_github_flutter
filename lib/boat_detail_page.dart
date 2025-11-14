import 'package:flutter/material.dart';
import 'boat_item.dart';

class BoatDetailPage extends StatelessWidget {
  final BoatItem boat;
  const BoatDetailPage({super.key, required this.boat});

  @override
  Widget build(BuildContext context) {
    final bool isFrench =
        Localizations.localeOf(context).languageCode == 'fr';

    return Scaffold(
      appBar: AppBar(
        title: Text(isFrench ? 'Détails du bateau' : 'Boat Details'),
        actions: [
          IconButton(
            tooltip: isFrench ? 'Aide' : 'Help',
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text(
                    isFrench
                        ? 'Aide pour l\'écran de détails'
                        : 'Boat Details Help',
                  ),
                  content: Text(
                    isFrench
                        ? 'Cet écran affiche les détails du bateau sélectionné.\n\n'
                        'Utilisez le bouton Retour pour revenir à la liste.'
                        : 'This screen shows the details of the selected boat.\n\n'
                        'Use the back button to return to the list.',
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _DetailPanel(boat: boat, isFrench: isFrench),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isFrench
                    ? 'Fonctionnalité à venir.'
                    : 'Feature coming soon!',
              ),
            ),
          );
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}

class _DetailPanel extends StatelessWidget {
  final BoatItem boat;
  final bool isFrench;

  const _DetailPanel({
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
