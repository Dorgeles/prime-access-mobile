import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:prime_access/models/movement.dart';
import 'package:prime_access/providers/movement_provider.dart';
import 'package:prime_access/providers/auth_provider.dart';
import 'package:prime_access/features/history/widgets/movement_filter_bar.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final movementProvider = context.read<MovementProvider>();
      movementProvider.loadMovements();
      final authProvider = context.read<AuthProvider>();
      final token = authProvider.user?.token ?? '';
      final userId = authProvider.user?.id ?? '';
      if (token.isNotEmpty && userId.isNotEmpty) {
        movementProvider.fetchFromServer(token, userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique'),
      ),
      body: Column(
        children: [
          const MovementFilterBar(),
          Expanded(
            child: Consumer<MovementProvider>(
              builder: (context, movementProvider, _) {
                final movements = movementProvider.movements;

                if (movements.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aucun historique de mouvements',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    final authProvider = context.read<AuthProvider>();
                    final token = authProvider.user?.token ?? '';
                    final userId = authProvider.user?.id ?? '';
                    await movementProvider.fetchFromServer(token, userId);
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: movements.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final movement = movements[index];
                      return _MovementCard(movement: movement);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MovementCard extends StatelessWidget {
  final Movement movement;

  const _MovementCard({required this.movement});

  @override
  Widget build(BuildContext context) {
    final isEntry = movement.type == MovementType.entry;
    final hasStatus = movement.hasStatusInfo;
    final isPending = movement.statusId == 14;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isEntry ? Colors.green[50] : Colors.orange[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isEntry ? Icons.login : Icons.logout,
                    color: isEntry ? Colors.green[700] : Colors.orange[700],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        movement.placeName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatDate(movement.timestamp),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isEntry ? Colors.green[50] : Colors.orange[50],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        movement.typeLabel,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isEntry
                              ? Colors.green[700]
                              : Colors.orange[700],
                        ),
                      ),
                    ),
                    if (movement.syncStatus == SyncStatus.pending)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Icon(
                          Icons.cloud_off,
                          size: 16,
                          color: Colors.grey[400],
                        ),
                      ),
                  ],
                ),
              ],
            ),
            if (hasStatus) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isPending ? Colors.orange[50] : Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      isPending ? Icons.hourglass_top : Icons.check_circle,
                      size: 16,
                      color: isPending ? Colors.orange[700] : Colors.green[700],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      movement.statusLabel,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isPending ? Colors.orange[800] : Colors.green[800],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} à '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}
