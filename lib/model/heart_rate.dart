class HeartRateRecovery {
  final int high;
  final int low;

  const HeartRateRecovery({required this.high, required this.low});

  int get delta => high - low;
}

class HrReading {
  final int timestamp; // Unix timestamp in seconds
  final int heartRate;

  const HrReading({required this.timestamp, required this.heartRate});
}
