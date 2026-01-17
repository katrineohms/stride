import 'package:flutter/material.dart';


class MoveSenseStatusCard extends StatelessWidget {
  // ======= Properties =======
  final bool connected;
  final int heartRate;
  final bool batteryOk;
  final VoidCallback? onTap;

  const MoveSenseStatusCard({
    super.key,
    required this.connected,
    required this.heartRate,
    required this.batteryOk,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        // ===== Leading Avatar, Bluetooth Icon =====
        leading: CircleAvatar(
          backgroundColor:
              connected ? Theme.of(context).colorScheme.primary : Colors.grey,
          child: const Icon(
            Icons.bluetooth,
            color: Colors.white,
          ),
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
                Icon(
                  batteryOk ? Icons.battery_full : Icons.battery_alert,
                  size: 20,
                  color: batteryOk ? Colors.green : Colors.red,
                ),
                const SizedBox(height: 4),
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
                Icon(
                  Icons.favorite,
                  size: 20,
                  color: heartRate > 0
                      ? const Color.fromARGB(255, 182, 78, 82)
                      : Colors.grey,
                ),
                const SizedBox(height: 4),
                const Text(
                  'HR',
                  style: TextStyle(fontSize: 11),
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
  // ======= Properties =======
  final bool connected;
  final int heartRate;

  const MovesenseStatusIcon({
    super.key,
    required this.connected,
    required this.heartRate,
  });

  // ======= Build UI =======
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min, // so the row doesn't stretch full width
        children: [
          if (connected) ...[
            Icon(
              Icons.bluetooth,
              size: 25,
              color: const Color.fromARGB(255, 255, 255, 255), // your blue
            ),
            const SizedBox(width: 0),
          ],

          // Heart rate overlay
          Padding(
            padding: const EdgeInsets.only(right: 5),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.favorite_outline,
                  size: 30, // slightly larger for overlay text
                  color: heartRate > 0 ? const Color.fromARGB(255, 255, 255, 255) : Colors.grey,
                ),
                Text(
                  heartRate > 0 ? heartRate.toString() : "",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// TODO make stateful with live data
