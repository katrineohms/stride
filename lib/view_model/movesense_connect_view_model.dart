import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:movesense_plus/movesense_plus.dart';
import 'package:permission_handler/permission_handler.dart';

enum ConnectionStatus { idle, connecting, connected, failed }

/// ViewModel for managing Movesense device connection
class MovesenseConnectViewModel extends ChangeNotifier {
  // State variables
  ConnectionStatus connectionStatus = ConnectionStatus.idle;
  List<MovesenseDevice> scannedDevices = [];
  MovesenseDevice? connectedDevice;
  bool isConnected = false;
  
  // Track connection states by device address
  final Map<String, bool> deviceConnectionStates = {};
  
  // Streams and subscriptions
  StreamSubscription<MovesenseDevice>? _deviceScanSubscription;
  StreamSubscription<dynamic>? _heartRateSubscription;
  Timer? _batteryCheckTimer;
  
  // Heart rate stream
  Stream<int>? heartRateStream;
  StreamController<int>? _heartRateController;
  
  // Battery stream
  Stream<String>? batteryStream;
  StreamController<String>? _batteryController;

  /// Start scanning for Movesense devices
  Future<void> scanDevices() async {
    // Request Bluetooth permissions for Android 12+
    if (Platform.isAndroid) {
      final scanStatus = await Permission.bluetoothScan.request();
      final connectStatus = await Permission.bluetoothConnect.request();
      
      if (!scanStatus.isGranted || !connectStatus.isGranted) {
        return;
      }
    }

    scannedDevices.clear();
    _deviceScanSubscription?.cancel();
    notifyListeners();

    _deviceScanSubscription = Movesense().devices.listen((device) {
      if (!scannedDevices.any((d) => d.address == device.address)) {
        scannedDevices.add(device);
        notifyListeners();
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
        return;
      }
    }

    // Set status to connecting
    connectionStatus = ConnectionStatus.connecting;
    connectedDevice = device;
    notifyListeners();

    try {
      device.connect();

      // Wait a bit to see if connection succeeds
      await Future.delayed(const Duration(seconds: 2));

      if (device.isConnected) {
        // Track connection state by device address
        deviceConnectionStates[device.address ?? ''] = true;
        
        connectionStatus = ConnectionStatus.connected;
        isConnected = true;
        
        // Create a StreamController for battery data
        _batteryController = StreamController<String>.broadcast();
        batteryStream = _batteryController!.stream;

        // Get initial battery status
        _updateBatteryStatus(device);

        // Check battery status every 30 seconds
        _batteryCheckTimer?.cancel();
        _batteryCheckTimer = Timer.periodic(const Duration(seconds: 30), (_) {
          _updateBatteryStatus(device);
        });

        // Create a StreamController for heart rate data
        _heartRateController = StreamController<int>.broadcast();
        heartRateStream = _heartRateController!.stream;

        // Listen to heart rate
        _heartRateSubscription?.cancel();
        _heartRateSubscription = device.hr.listen((hr) {
          print('Heart Rate: ${hr.average}, R-R: ${hr.rr}');
          _heartRateController!.add(hr.average.toInt());
        });

        // Listen to device status
        device.statusEvents.listen((status) {
          print('Device status: ${status.name}');
        });

        notifyListeners();
      } else {
        // Connection failed
        deviceConnectionStates[device.address ?? ''] = false;
        connectionStatus = ConnectionStatus.failed;
        isConnected = false;
        notifyListeners();

        // Reset to idle after 3 seconds
        await Future.delayed(const Duration(seconds: 3));
        connectionStatus = ConnectionStatus.idle;
        connectedDevice = null;
        notifyListeners();
      }
    } catch (e) {
      print('Error connecting: $e');
      deviceConnectionStates[device.address ?? ''] = false;
      connectionStatus = ConnectionStatus.failed;
      isConnected = false;
      notifyListeners();

      // Reset to idle after 3 seconds
      await Future.delayed(const Duration(seconds: 3));
      connectionStatus = ConnectionStatus.idle;
      connectedDevice = null;
      notifyListeners();
    }
  }

  /// Update battery status from device
  Future<void> _updateBatteryStatus(MovesenseDevice device) async {
    try {
      final battery = await device.getBatteryStatus();
      final batteryStatus = battery.name;
      print('Battery level: $batteryStatus');
      _batteryController!.add(batteryStatus);
    } catch (e) {
      print('Error fetching battery: $e');
    }
  }

  /// Stop scanning for devices
  void stopScanning() {
    Movesense().stopScan();
    _deviceScanSubscription?.cancel();
  }

  /// Get connection status text
  String getConnectionStatusText() {
    switch (connectionStatus) {
      case ConnectionStatus.connecting:
        return 'Connecting...';
      case ConnectionStatus.connected:
        return connectedDevice?.name ?? 'Connected';
      case ConnectionStatus.failed:
        return 'Could not connect to device';
      case ConnectionStatus.idle:
        return 'Disconnected';
    }
  }

  /// Get connection status color
  Color getConnectionStatusColor() {
    switch (connectionStatus) {
      case ConnectionStatus.connected:
        return Colors.green;
      case ConnectionStatus.connecting:
        return Colors.orange;
      case ConnectionStatus.failed:
        return Colors.red;
      case ConnectionStatus.idle:
        return Colors.grey;
    }
  }

  @override
  void dispose() {
    stopScanning();
    _heartRateSubscription?.cancel();
    _heartRateController?.close();
    _batteryCheckTimer?.cancel();
    _batteryController?.close();
    super.dispose();
  }
}
