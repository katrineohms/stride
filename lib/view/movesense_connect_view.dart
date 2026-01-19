import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:movesense_plus/movesense_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../widgets/movesense_status_widget.dart';

/// Movesense Connect Page
class MovesenseConnectView extends StatefulWidget {
  const MovesenseConnectView({super.key});

  @override
  State<MovesenseConnectView> createState() => _MovesenseConnectViewState();
}

class _MovesenseConnectViewState extends State<MovesenseConnectView> {
  bool isConnected = false;
  MovesenseDevice? connectedDevice;
  List<MovesenseDevice> scannedDevices = [];
  StreamSubscription<MovesenseDevice>? deviceScanSubscription;

  @override
  void initState() {
    super.initState();
    // Optionally, request permissions here if needed
  }

  @override
  void dispose() {
    Movesense().stopScan();
    deviceScanSubscription?.cancel();
    super.dispose();
  }

  /// Start scanning for devices
  Future<void> scanDevices() async {
    // Request Bluetooth permissions for Android 12+
    if (Platform.isAndroid) {
      final scanStatus = await Permission.bluetoothScan.request();
      final connectStatus = await Permission.bluetoothConnect.request();
      
      if (!scanStatus.isGranted || !connectStatus.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bluetooth permissions denied')),
          );
        }
        return;
      }
    }

    scannedDevices.clear();
    deviceScanSubscription?.cancel();

    deviceScanSubscription = Movesense().devices.listen((device) {
      if (!scannedDevices.any((d) => d.address == device.address)) {
        setState(() {
          scannedDevices.add(device);
        });
      }
    });

    Movesense().scan();
  }

  /// Connect to a Movesense device
  Future<void> connectDevice(MovesenseDevice device) async {
    // Request BLUETOOTH_CONNECT permission if needed
    if (Platform.isAndroid) {
      final status = await Permission.bluetoothConnect.request();
      if (!status.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bluetooth connect permission denied')),
          );
        }
        return;
      }
    }

    device.connect();

    // Update UI
    setState(() {
      connectedDevice = device;
      isConnected = device.isConnected;
    });

    // Listen to heart rate and status
    device.hr.listen((hr) {
      print('Heart Rate: ${hr.average}, R-R: ${hr.rr}');
      // You could also update a variable and call setState to show it in the UI
    });

    device.statusEvents.listen((status) {
      print('Device status: ${status.name}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect'),
        actions: [
          MovesenseStatusIcon(
            connected: isConnected,
            heartRate: 0, // TODO: bind to real heart rate if needed
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
                      ? (connectedDevice?.name ?? 'Connected')
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
                onPressed: scanDevices,
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
                      title: Text(device.name ?? 'Unknown Device'),
                      subtitle: Text(device.address ?? ''),
                      trailing: ElevatedButton(
                        child: const Text('Connect'),
                        onPressed: () => connectDevice(device),
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
