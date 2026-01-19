class MovesenseDevice {
  final bool connected;
  final int heartRate;
  final String batteryStatus;

  MovesenseDevice({
    required this.connected,
    required this.heartRate,
    required this.batteryStatus,
  });
}
