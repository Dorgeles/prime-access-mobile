import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:prime_access/models/movement.dart';
import 'package:prime_access/providers/movement_provider.dart';
import 'package:prime_access/providers/auth_provider.dart';

class ConfirmationScreen extends StatelessWidget {
  final String qrData;
  final String latitude;
  final String longitude;

  const ConfirmationScreen({
    super.key,
    required this.qrData,
    required this.latitude,
    required this.longitude,
  });

  @override
  Widget build(BuildContext context) {
    final movementProvider = context.read<MovementProvider>();
    final user = context.read<AuthProvider>().user;

    final lastMovement = movementProvider.lastMovement;
    final isEntry =
        lastMovement == null ||
        lastMovement.placeId != _getPlaceIdFromQr() ||
        lastMovement.type == MovementType.exit;

    final placeName = _getPlaceNameFromQr();

    return Scaffold(
      appBar: AppBar(title: const Text('Confirmer le mouvement')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            Icon(
              isEntry ? Icons.login : Icons.logout,
              size: 80,
              color: isEntry ? Colors.green : Colors.orange,
            ),
            const SizedBox(height: 24),
            Text(
              isEntry ? 'Entrée' : 'Sortie',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isEntry ? Colors.green[700] : Colors.orange[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              placeName,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'QR Code scanné',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    qrData,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Date : ${_formatNow()}',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () async {
                final movement = Movement(
                  id: 'mov-${DateTime.now().millisecondsSinceEpoch}',
                  userId: user?.id ?? 'unknown',
                  placeId: "1",
                  placeName: "Ailes Sale TV",
                  type: isEntry ? MovementType.entry : MovementType.exit,
                  timestamp: DateTime.now(),
                  qrData: qrData,
                  syncStatus: SyncStatus.synced,
                  latitude: latitude,
                  longitude: longitude,
                );

                final result = await movementProvider.addMovement(
                  movement,
                  user?.token,
                );

                if (!context.mounted) return;

                final syncFailed = result != null && result.success;
                final isRejected = result!.errorCode == '800';

                if (!isRejected) {
                  final message = result.errorMessage ?? 'Erreur inconnue';
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur ${result.errorCode} : $message'),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 4),
                      action: SnackBarAction(
                        label: 'OK',
                        textColor: Colors.white,
                        onPressed: () {},
                      ),
                    ),
                  );
                }

                context.go('/dashboard');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    duration: Duration(seconds: isRejected ? 2 : 4),
                    content: Text(
                      isRejected
                          ? 'Mouvement rejeté par le serveur : $placeName'
                          : syncFailed
                          ? 'Mouvement enregistré localement et en attente de synchronisation'
                          : 'Mouvement enregistré avec succès : $placeName',
                    ),
                    backgroundColor: isRejected
                        ? Colors.green
                        : syncFailed
                        ? Colors.red
                        : Colors.orange,
                  ),
                );
              },
              child: const Text('Confirmer'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => context.pop(),
              child: const Text('Annuler'),
            ),
          ],
        ),
      ),
    );
  }

  String _getPlaceIdFromQr() {
    final parts = qrData.split(':');
    if (parts.length >= 2 && parts[0] == 'place') {
      return parts[1];
    }
    return 'unknown';
  }

  String _getPlaceNameFromQr() {
    final parts = qrData.split(':');
    if (parts.length >= 2 && parts[0] == 'place') {
      return parts.length >= 3 ? parts[2] : parts[1];
    }
    return qrData;
  }

  String _formatNow() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}/'
        '${now.month.toString().padLeft(2, '0')}/'
        '${now.year} à '
        '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}';
  }
}
