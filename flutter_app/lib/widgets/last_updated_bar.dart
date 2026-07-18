import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LastUpdatedBar extends StatelessWidget {
  final DateTime? lastUpdated;

  const LastUpdatedBar({super.key, required this.lastUpdated});

  @override
  Widget build(BuildContext context) {
    final text = lastUpdated == null
        ? 'Waiting for first update...'
        : 'Last updated: ${DateFormat.Hms().format(lastUpdated!)}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(Icons.sync, size: 14, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
