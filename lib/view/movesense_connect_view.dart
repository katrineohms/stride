import 'package:flutter/material.dart';
import '../view_model/movesense_connect_view_model.dart';
import '../widgets/movesense_status_widget.dart';

/// Movesense Connect Page
class MovesenseConnectView extends StatefulWidget {
  const MovesenseConnectView({super.key});

  @override
  State<MovesenseConnectView> createState() => _MovesenseConnectViewState();
}

class _MovesenseConnectViewState extends State<MovesenseConnectView> {
  // Static ViewModel to persist across navigation
  static final MovesenseConnectViewModel _sharedViewModel = MovesenseConnectViewModel();
  
  late MovesenseConnectViewModel viewModel;

  @override
  void initState() {
    super.initState();
    // Use the shared ViewModel instead of creating a new one
    viewModel = _sharedViewModel;
  }

  @override
  void dispose() {
    // Don't dispose the shared ViewModel here - it should persist
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect'),
        actions: [
          ListenableBuilder(
            listenable: viewModel,
            builder: (context, _) {
              return MovesenseStatusIcon(
                connected: viewModel.isConnected,
                heartRate: 0,
                heartRateStream: viewModel.heartRateStream,
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListenableBuilder(
          listenable: viewModel,
          builder: (context, _) {
            return Column(
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
                      color: viewModel.getConnectionStatusColor(),
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(viewModel.getConnectionStatusText()),
                  ],
                ),
                const SizedBox(height: 16),

                // Scan Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.search),
                    label: const Text('Scan Devices'),
                    onPressed: () => viewModel.scanDevices(),
                  ),
                ),
                const SizedBox(height: 16),

                // List of scanned devices
                if (viewModel.scannedDevices.isNotEmpty)
                  const Text(
                    'Available Devices:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: viewModel.scannedDevices.length,
                    itemBuilder: (context, index) {
                      final device = viewModel.scannedDevices[index];
                      return Card(
                        child: ListTile(
                          title: Text(device.name ?? 'Unknown Device'),
                          subtitle: Text(device.address ?? ''),
                          trailing: ElevatedButton(
                            child: const Text('Connect'),
                            onPressed: () => viewModel.connectDevice(device),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
