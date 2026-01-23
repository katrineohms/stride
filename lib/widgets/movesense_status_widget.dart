// ===============================
// Packages
// ===============================
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// ===============================
// Files
// ===============================
import '../view_model/movesense_connect_view_model.dart';

// ===============================
// Movesense Status Widgets
// ===============================

// ====== App Bar Status Widget ======
/// Reusable wrapper for Movesense status in app bars across views.
/// Subscribes to ViewModel and renders the connection/HR icon.
class MovesenseAppBarStatus extends StatelessWidget {
  final MovesenseConnectViewModel viewModel;

  const MovesenseAppBarStatus({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return MovesenseStatusIcon(
          connected: viewModel.isConnected,
          heartRate: 0,
          heartRateStream: viewModel.heartRateStream,
        );
      },
    );
  }
}

// ====== Status Card Widget ======
class MoveSenseStatusCard extends StatelessWidget {
  // ====== Properties ======
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
      color: Theme.of(context).cardColor,
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
                if (!connected)
                  const Icon(
                    Icons.battery_unknown,
                    size: 20,
                    color: Colors.grey,
                  )
                else if (batteryStream != null)
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
                if (!connected)
                  const Text(
                    '?',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  )
                else if (batteryStream != null)
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
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
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
          Stack(
            clipBehavior: Clip.none,
            children: [
              // White circle behind error
              if (!connected)
                Container(
                  width: 25,
                  height: 25,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),

              // Main icon
              Icon(
                connected ? Icons.bluetooth : Icons.error,
                size: 25,
                color: connected ? Colors.white : Colors.red,
              ),

              // Overlay small green check when connected
              if (connected)
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green,
                      border: Border.fromBorderSide(
                        BorderSide(color: Colors.white, width: 1),
                      ),
                    ),
                    child: const Icon(Icons.done, size: 8, color: Colors.white),
                  ),
                ),
            ],
          ),

          const SizedBox(width: 4),

          // ===== Heart rate =====
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
                          SvgPicture.asset(
                            'assets/icons/heart_outline_24.svg',
                            width: 31,
                            height: 31,
                          ),
                          Transform.translate(
                            offset: const Offset(0, -1),
                            child: Text(
                              hr.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink();
              },
            ),
        ],
      ),
    );
  }
}
