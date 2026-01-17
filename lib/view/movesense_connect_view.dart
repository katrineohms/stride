import 'package:flutter/material.dart';
import '../widgets/movesense_status_widget.dart';

/// Movesense Connect Page
class MovesenseConnectView extends StatefulWidget {
  const MovesenseConnectView({super.key});

  @override
  State<MovesenseConnectView> createState() => _MovesenseConnectViewState();
}

class _MovesenseConnectViewState extends State<MovesenseConnectView> {
  bool isConnected = false;
  String? connectedDevice;
  List<String> scannedDevices = []; // Will be populated by your plugin


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect'),
        actions: [
          MovesenseStatusIcon(
            connected: isConnected,
            heartRate: 0, // TODO: bind to real heart rate
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status
            Row(
              children: [
                const Text(
                  'Connection Status: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Icon(
                  Icons.circle,
                  color: isConnected ? Colors.green : Colors.red,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  isConnected
                      ? (connectedDevice ?? 'Connected')
                      : 'Disconnected',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Scan Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.search),
                label: const Text('Scan Devices'),
                onPressed: null, // TODO: implement scanning
              ),
            ),
            const SizedBox(height: 16),

            // List of scanned devices
            if (scannedDevices.isNotEmpty)
              const Text(
                'Available Devices:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: scannedDevices.length,
                itemBuilder: (context, index) {
                  final device = scannedDevices[index];
                  return Card(
                    child: ListTile(
                      title: Text(device),
                      trailing: ElevatedButton(
                        child: const Text('Connect'),
                        onPressed: () {}, // TODO: implement connection
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
