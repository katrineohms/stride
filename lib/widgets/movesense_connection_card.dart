// Packages
import 'package:flutter/material.dart';

/// Movesense connection card - shows connection status and allows navigation
class MovesenseConnectionCard extends StatelessWidget {
  final bool isConnected;
  final Stream<int>? heartRateStream;
  final VoidCallback? onTap;

  const MovesenseConnectionCard({
    super.key,
    required this.isConnected,
    this.heartRateStream,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: const Icon(Icons.bluetooth),
        title: const Text('Movesense Connection'),
        subtitle: Text(isConnected ? 'Connected' : 'Not connected'),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
