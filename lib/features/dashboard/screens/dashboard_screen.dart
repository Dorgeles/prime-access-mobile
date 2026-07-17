import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:prime_access/providers/movement_provider.dart';
import 'package:prime_access/features/dashboard/widgets/last_movement_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prime Access'),
      ),
      body: Consumer<MovementProvider>(
        builder: (context, movementProvider, _) {
          return RefreshIndicator(
            onRefresh: () async {
              movementProvider.loadMovements();
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Bonjour,',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  'Que souhaitez-vous faire ?',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 160,
                  child: Card(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => context.push('/scan'),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.qr_code_scanner,
                              size: 48,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Scanner un QR code',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Dernier mouvement',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                LastMovementCard(
                  lastMovement: movementProvider.lastMovement,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
