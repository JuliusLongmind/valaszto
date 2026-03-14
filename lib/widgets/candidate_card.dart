import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/jelolt.dart';

class CandidateCard extends StatelessWidget {
  final Jelolt jelolt;
  final VoidCallback onTap;

  const CandidateCard({
    super.key,
    required this.jelolt,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAvatar(),
              const SizedBox(width: 16),
              Expanded(child: _buildInfo(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Stack(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: _getPartColor(jelolt.part),
          child: jelolt.kepUrl != null && jelolt.kepUrl!.isNotEmpty
              ? ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: jelolt.kepUrl!,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => _buildInitials(),
                    errorWidget: (context, url, error) => _buildInitials(),
                  ),
                )
              : _buildInitials(),
        ),
        if (jelolt.verificated)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                size: 12,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInitials() {
    final initials = jelolt.nev.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join();
    return Text(
      initials,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    );
  }

  Widget _buildInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getPartColor(jelolt.part),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${jelolt.sorszam}.',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                jelolt.nev,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: _getPartColor(jelolt.part).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            jelolt.part,
            style: TextStyle(
              color: _getPartColor(jelolt.part),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        if (jelolt.rovidUzenet != null) ...[
          const SizedBox(height: 8),
          Text(
            jelolt.rovidUzenet!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
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
