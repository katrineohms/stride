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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        // ===== Leading Avatar, Bluetooth Icon =====
        leading: CircleAvatar(
          backgroundColor: isConnected
              ? Theme.of(context).colorScheme.primary
              : Colors.grey,
          child: const Icon(Icons.bluetooth, color: Colors.white),
        ),

        // ===== Title & Subtitle =====
        title: const Text('Movesense Sensor'),
        subtitle: Row(
          children: [
            Icon(
              isConnected ? Icons.check_circle : Icons.error,
              size: 16,
              color: isConnected ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 4),
            Text(
              isConnected ? 'Connected' : 'No device connected',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),

        // ===== Trailing Heart Rate =====
        trailing: isConnected && heartRateStream != null
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  StreamBuilder<int>(
                    stream: heartRateStream,
                    initialData: 0,
                    builder: (context, snapshot) {
                      final hr = snapshot.data ?? 0;
                      return Icon(
                        Icons.favorite,
                        size: 20,
                        color: hr > 0
                            ? const Color.fromARGB(255, 210, 57, 62)
                            : Colors.grey,
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                  StreamBuilder<int>(
                    stream: heartRateStream,
                    initialData: 0,
                    builder: (context, snapshot) {
                      final hr = snapshot.data ?? 0;
                      return Text(
                        '$hr',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ],
              )
            : null,

        onTap: onTap,
      ),
    );
  }
}
