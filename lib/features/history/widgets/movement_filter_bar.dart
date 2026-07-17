import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:prime_access/providers/movement_provider.dart';

class MovementFilterBar extends StatefulWidget {
  const MovementFilterBar({super.key});

  @override
  State<MovementFilterBar> createState() => _MovementFilterBarState();
}

class _MovementFilterBarState extends State<MovementFilterBar> {
  @override
  Widget build(BuildContext context) {
    final movementProvider = context.watch<MovementProvider>();
    final hasFilters = movementProvider.filterType != 'all' ||
        movementProvider.filterStartDate != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(
                        label: 'Type',
                        value: movementProvider.filterType == 'all'
                            ? 'Tous'
                            : movementProvider.filterType == 'entry'
                                ? 'Entrée'
                                : 'Sortie',
                        onTap: () => _showTypeFilter(movementProvider),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Date',
                        value: movementProvider.filterStartDate != null
                            ? 'Personnalisée'
                            : 'Toutes',
                        onTap: () =>
                            _showDateFilter(movementProvider),
                      ),
                    ],
                  ),
                ),
              ),
              if (hasFilters)
                IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: () {
                    movementProvider.clearFilters();
                  },
                  tooltip: 'Effacer les filtres',
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showTypeFilter(MovementProvider movementProvider) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Filtrer par type',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            RadioGroup<String>(
              groupValue: movementProvider.filterType,
              onChanged: (String? value) {
                if (value == null) return;
                movementProvider.setFilterType(value);
                Navigator.pop(context);
              },
              child: const Column(
                children: [
                  RadioListTile<String>(
                    value: 'all',
                    title: Text('Tous'),
                  ),
                  RadioListTile<String>(
                    value: 'entry',
                    title: Text('Entrée'),
                  ),
                  RadioListTile<String>(
                    value: 'exit',
                    title: Text('Sortie'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDateFilter(MovementProvider movementProvider) async {
    DateTimeRange? dateRange;
    if (movementProvider.filterStartDate != null &&
        movementProvider.filterEndDate != null) {
      dateRange = DateTimeRange(
        start: movementProvider.filterStartDate!,
        end: movementProvider.filterEndDate!,
      );
    }

    final result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: dateRange,
      helpText: 'Sélectionner une période',
      cancelText: 'Annuler',
      confirmText: 'Appliquer',
      fieldStartLabelText: 'Du',
      fieldEndLabelText: 'Au',
    );

    if (result != null) {
      movementProvider.setFilterDateRange(result.start, result.end);
    }
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.primary),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$label: ',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              size: 18,
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}
