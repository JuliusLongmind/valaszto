import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/jelolt.dart';

class CandidateDetailScreen extends StatelessWidget {
  final Jelolt jelolt;

  const CandidateDetailScreen({super.key, required this.jelolt});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(jelolt.nev),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [_buildHeader(context), _buildContent(context)],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
      ),
      child: Column(
        children: [
          if (jelolt.kepUrl != null && jelolt.kepUrl!.isNotEmpty)
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: jelolt.kepUrl!,
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => _buildInitialsAvatar(),
                  errorWidget: (context, url, error) => _buildInitialsAvatar(),
                ),
              ),
            )
          else
            _buildInitialsAvatar(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getPartColor(jelolt.part),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${jelolt.sorszam}.',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getPartColor(jelolt.part).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  jelolt.part,
                  style: TextStyle(
                    color: _getPartColor(jelolt.part),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (jelolt.verificated)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.verified, size: 16, color: Colors.green[700]),
                const SizedBox(width: 4),
                Text(
                  'Párt által hitelesített tartalom',
                  style: TextStyle(color: Colors.green[700], fontSize: 12),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildInitialsAvatar() {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: _getPartColor(jelolt.part),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          jelolt.nev
              .split(' ')
              .map((e) => e.isNotEmpty ? e[0] : '')
              .take(2)
              .join(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 64,
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          jelolt.valasztokeruletNev,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    'Bemutatkozás',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    jelolt.teljesUzenet ??
                        jelolt.rovidUzenet ??
                        'Nincs üzenet.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pártinformáció',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildPartyInfo(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartyInfo(BuildContext context) {
    final Map<String, String> partyDescriptions = {
      'FIDESZ-KDNP':
          'Fidesz - Magyar Polgári Szövetség és Kereszténydemokrata Néppárt',
      'TISZA': 'Tisztelet és Szabadság Párt',
      'DK': 'Demokratikus Koalíció',
      'Jobbik': 'Jobbik Magyarországért Mozgalom',
      'Mi Hazánk': 'Mi Hazánk Mozgalom',
      'MKKP': 'Magyar Kétfarkú Kutya Párt',
      'MSZP': 'Magyar Szocialista Párt',
      'LMP': 'Lehet Más a Politika',
      'Független': 'Független jelölt',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: _getPartColor(jelolt.part),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                partyDescriptions[jelolt.part] ?? jelolt.part,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getPartColor(String part) {
    switch (part.toUpperCase()) {
      case 'FIDESZ-KDNP':
        return Colors.orange;
      case 'TISZA':
        return Colors.purple;
      case 'DK':
        return Colors.blue;
      case 'JOBBIK':
        return Colors.green;
      case 'MI HAZÁNK':
        return Colors.red;
      case 'MKKP':
        return Colors.black;
      case 'MSZP':
        return Colors.pink;
      case 'LMP':
        return Colors.lightGreen;
      default:
        return Colors.grey;
    }
  }
}
