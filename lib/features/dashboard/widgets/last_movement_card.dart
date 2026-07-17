import 'package:flutter/material.dart';
import 'package:prime_access/models/movement.dart';

class LastMovementCard extends StatelessWidget {
  final Movement? lastMovement;

  const LastMovementCard({super.key, this.lastMovement});

  @override
  Widget build(BuildContext context) {
    if (lastMovement == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.info_outline,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 12),
              Text(
                'Aucun mouvement enregistré',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Scannez un QR code pour commencer',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                    ),
              ),
            ],
          ),
        ),
      );
    }

    final movement = lastMovement!;
    final isEntry = movement.type == MovementType.entry;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isEntry
                        ? Colors.green[50]
                        : Colors.orange[50],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isEntry ? Icons.login : Icons.logout,
                        size: 16,
                        color: isEntry ? Colors.green[700] : Colors.orange[700],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        movement.typeLabel,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color:
                              isEntry ? Colors.green[700] : Colors.orange[700],
                        ),
                      ),
                    ],
                  ),
                ),
                if (movement.syncStatus == SyncStatus.pending)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Icon(
                      Icons.cloud_off,
                      size: 18,
                      color: Colors.grey[500],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              movement.placeName,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatDateTime(movement.timestamp),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) return 'À l\'instant';
    if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes} min';
    }
    if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours}h';
    }
    if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays}j';
    }
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} à ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
