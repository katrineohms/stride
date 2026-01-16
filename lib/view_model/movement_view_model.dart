import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class MovesenseViewModel extends ChangeNotifier {
  final FlutterReactiveBle _ble = FlutterReactiveBle();

  final List<DiscoveredDevice> _devices = [];
  List<DiscoveredDevice> get devices => List.unmodifiable(_devices);

  String? _connectedDeviceId;
  bool get isConnected => _connectedDeviceId != null;

  StreamSubscription? _scanSub;
  StreamSubscription? _connSub;

  void startScan() {
    _devices.clear();
    notifyListeners();

    _scanSub?.cancel();
    _scanSub = _ble.scanForDevices(
      withServices: const [],
      scanMode: ScanMode.lowLatency,
    ).listen((device) {
      if (device.name.toLowerCase().contains('movesense')) {
        if (_devices.every((d) => d.id != device.id)) {
          _devices.add(device);
          notifyListeners();
        }
      }
    });
  }

  Future<void> connect(String deviceId) async {
    _connSub?.cancel();
    _connSub = _ble.connectToDevice(id: deviceId).listen((update) {
      if (update.connectionState == DeviceConnectionState.connected) {
        _connectedDeviceId = deviceId;
        notifyListeners();
      }
      if (update.connectionState == DeviceConnectionState.disconnected) {
        _connectedDeviceId = null;
        notifyListeners();
      }
    });
  }

  Future<void> disconnect() async {
    await _connSub?.cancel();
    _connectedDeviceId = null;
    notifyListeners();
  }
}