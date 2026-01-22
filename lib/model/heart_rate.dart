// Currently unused

class HeartRateRecovery {
  final int high;
  final int low;
  final int timestamp; // Unix timestamp (seconds)

  const HeartRateRecovery({
    required this.high,
    required this.low,
    required this.timestamp,
  });

  int get delta => high - low;
}

class HrReading {
  final int timestamp;
  final int heartRate;

  const HrReading({required this.timestamp, required this.heartRate});
}
