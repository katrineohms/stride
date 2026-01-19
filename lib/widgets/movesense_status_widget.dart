import 'package:flutter/material.dart';

class MoveSenseStatusCard extends StatelessWidget {
  // ======= Properties =======
  final bool connected;
  final int heartRate;
  final Stream<int>? heartRateStream;
  final bool batteryOk;
  final Stream<String>? batteryStream;
  final VoidCallback? onTap;

  const MoveSenseStatusCard({
    super.key,
    required this.connected,
    required this.heartRate,
    this.heartRateStream,
    required this.batteryOk,
    this.batteryStream,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        // ===== Leading Avatar, Bluetooth Icon =====
        leading: CircleAvatar(
          backgroundColor: connected
              ? Theme.of(context).colorScheme.primary
              : Colors.grey,
          child: const Icon(Icons.bluetooth, color: Colors.white),
        ),

        // ===== Title & Subtitle =====
        title: const Text('Movesense Sensor'),
        subtitle: Row(
          children: [
            Icon(
              connected ? Icons.check_circle : Icons.error,
              size: 16,
              color: connected ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 4),
            Text(
              connected ? 'Connected' : 'No device connected',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),

        // ===== Trailing Icons =====
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ===== Battery =====
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (batteryStream != null)
                  StreamBuilder<String>(
                    stream: batteryStream,
                    initialData: batteryOk ? 'ok' : 'low',
                    builder: (context, snapshot) {
                      final batteryStatus = snapshot.data ?? 'low';
                      final isOk = batteryStatus == 'ok';
                      return Icon(
                        isOk ? Icons.battery_full : Icons.battery_alert,
                        size: 20,
                        color: isOk ? Colors.green : Colors.red,
                      );
                    },
                  )
                else
                  Icon(
                    batteryOk ? Icons.battery_full : Icons.battery_alert,
                    size: 20,
                    color: batteryOk ? Colors.green : Colors.red,
                  ),
                const SizedBox(height: 4),
                if (batteryStream != null)
                  StreamBuilder<String>(
                    stream: batteryStream,
                    initialData: batteryOk ? 'ok' : 'low',
                    builder: (context, snapshot) {
                      final batteryStatus = snapshot.data ?? 'low';
                      final isOk = batteryStatus == 'ok';
                      return Text(
                        isOk ? 'OK' : 'Low',
                        style: const TextStyle(fontSize: 11),
                      );
                    },
                  )
                else
                  Text(
                    batteryOk ? 'OK' : 'Low',
                    style: const TextStyle(fontSize: 11),
                  ),
              ],
            ),
            const SizedBox(width: 12),

            // ===== Heart Rate =====
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (heartRateStream != null)
                  StreamBuilder<int>(
                    stream: heartRateStream,
                    initialData: heartRate,
                    builder: (context, snapshot) {
                      final hr = snapshot.data ?? heartRate;
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.favorite,
                            size: 20,
                            color: hr > 0
                                ? const Color.fromARGB(255, 210, 57, 62)
                                : Colors.grey,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$hr',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      );
                    },
                  )
                else
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.favorite,
                        size: 20,
                        color: heartRate > 0
                            ? const Color.fromARGB(255, 210, 57, 62)
                            : Colors.grey,
                      ),
                      const SizedBox(height: 4),
                      const Text('HR', style: TextStyle(fontSize: 11)),
                    ],
                  ),
              ],
            ),
          ],
        ),

        // ===== OnTap Handler =====
        onTap: onTap,
      ),
    );
  }
}
// ======= Movesense Status Icon Widget =======
class MovesenseStatusIcon extends StatelessWidget {
  final bool connected;
  final int heartRate;
  final Stream<int>? heartRateStream;

  const MovesenseStatusIcon({
    super.key,
    required this.connected,
    required this.heartRate,
    this.heartRateStream,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ===== Connection status =====
          Icon(
            connected ? Icons.bluetooth : Icons.error,
            size: 25,
            color: connected ? Colors.white : Colors.red,
          ),
          const SizedBox(width: 4),

          // ===== Heart rate (optional) =====
          if (heartRateStream != null)
            StreamBuilder<int>(
              stream: heartRateStream,
              initialData: heartRate,
              builder: (context, snapshot) {
                final hr = snapshot.data ?? heartRate;
                return hr > 0
                    ? Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(
                            Icons.favorite_outline,
                            size: 30,
                            color: Colors.white,
                          ),
                          Text(
                            hr.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink();
              },
            )
        ],
      ),
    );
  }
}


// TODO make stateful with live data
