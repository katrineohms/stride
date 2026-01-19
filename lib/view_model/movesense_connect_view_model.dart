import 'dart:async';
import 'package:flutter/material.dart';
import 'package:movesense_plus/movesense_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class MovesenseDemo extends StatefulWidget {
  @override
  State<MovesenseDemo> createState() => _MovesenseDemoState();
}

class _MovesenseDemoState extends State<MovesenseDemo> {
  List<MovesenseDevice> devices = [];
  bool scanning = false;
  String statusMessage = '';
  Timer? scanTimeout;
  StreamSubscription<MovesenseDevice>? _deviceSub;

  @override
  void initState() {
    super.initState();
    startScan();
  }

  /// Request necessary Bluetooth & location permissions
  Future<bool> requestPermissions() async {
    final statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();

    return statuses.values.every((status) => status.isGranted);
  }

  /// Start scanning for Movesense devices
  void startScan() async {
    final granted = await requestPermissions();
    if (!granted) {
      setState(() {
        scanning = false;
        statusMessage = 'Permissions denied. Cannot scan.';
      });
      return;
    }

    // Clear previous scan results
    _deviceSub?.cancel();
    setState(() {
      devices.clear();
      scanning = true;
      statusMessage = 'Scanning for devices...';
    });

    // Listen for scanned devices
    _deviceSub = Movesense().devices.listen((device) {
      setState(() {
        if (!devices.any((d) => d.address == device.address)) {
          devices.add(device);
        }
      });
    });

    try {
      Movesense().scan();
    } catch (e) {
      setState(() {
        scanning = false;
        statusMessage = 'Scan failed: $e';
      });
      return;
    }

    // Stop scan if no devices are found within 15 seconds
    scanTimeout?.cancel();
    scanTimeout = Timer(const Duration(seconds: 15), () {
      Movesense().stopScan();
      _deviceSub?.cancel();
      if (devices.isEmpty) {
        setState(() {
          scanning = false;
          statusMessage = 'No devices found. Try again.';
        });
      }
    });
  }

  /// Connect to selected device and listen to status & heart rate
  void connectToDevice(MovesenseDevice device) async {
    setState(() {
      statusMessage = 'Connecting to ${device.name}...';
    });

    try {
      device.connect(); // await connection
      setState(() {
        scanning = false;
        statusMessage = 'Connected to ${device.name}';
      });

      // Listen to device status
      device.statusEvents.listen((status) {
        print('Device status: ${status.name}');
      });

      // Listen to heart rate
      device.hr.listen((hr) {
        print('Heart Rate: ${hr.average}, R-R Interval: ${hr.rr}');
      });
    } catch (e) {
      setState(() {
        statusMessage = 'Failed to connect: $e';
      });
    }
  }

  @override
  void dispose() {
    scanTimeout?.cancel();
    _deviceSub?.cancel();
    Movesense().stopScan();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Movesense Devices')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (statusMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(statusMessage),
              ),
            Expanded(
              child: ListView.builder(
                itemCount: devices.length,
                itemBuilder: (_, index) {
                  final device = devices[index];
                  return Card(
                    child: ListTile(
                      title: Text(device.name ?? 'Unknown Device'),
                      subtitle: Text(device.address ?? 'Unknown Address'),
                      trailing: ElevatedButton(
                        child: const Text('Connect'),
                        onPressed: () => connectToDevice(device),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Scan Again'),
                onPressed: scanning ? null : startScan,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
