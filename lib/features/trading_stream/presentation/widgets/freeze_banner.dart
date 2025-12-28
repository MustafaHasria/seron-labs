import 'package:flutter/material.dart';

/// Banner shown when deltaCount > 50 after unfreezing.
class FreezeBanner extends StatelessWidget {
  final VoidCallback onJumpToLatest;

  const FreezeBanner({
    super.key,
    required this.onJumpToLatest,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(
              Icons.notifications_active,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'More than 50 trades received while frozen. Jump to latest?',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
              ),
            ),
            TextButton(
              onPressed: onJumpToLatest,
              child: const Text('Jump to Latest'),
            ),
          ],
        ),
      ),
    );
  }
}

