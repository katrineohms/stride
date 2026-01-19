import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

import '../model/clients.dart';
import '../service/client_data_service.dart';
import '../service/movesense_service.dart';
import '../view/client_card_view.dart';
import '../view/edit_client_view.dart';
import '../widgets/movesense_status_widget.dart';
import '../widgets/stop_watch_timer_widget.dart';

/// ===== Helper =====
Color getStatusColor(int active) {
  switch (active) {
    case 0:
      return Colors.green;
    case 1:
      return Colors.yellow;
    case 2:
      return Colors.red;
    default:
      return Colors.grey;
  }
}

/// ===== Helper to get next upcoming appointment =====
DateTime? getNextAppointment(Client client) {
  final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  final futureAppointments = client.appointments
      .where((a) => a.timestamp >= now)
      .toList();

  if (futureAppointments.isEmpty) return null;

  futureAppointments.sort((a, b) => a.timestamp.compareTo(b.timestamp));
  return DateTime.fromMillisecondsSinceEpoch(
    futureAppointments.first.timestamp * 1000,
  );
}

/// ===== Client Card =====
class ClientCard extends StatelessWidget {
  final Client client;
  final VoidCallback? onTap;

  const ClientCard({super.key, required this.client, this.onTap});

  @override
  Widget build(BuildContext context) {
    final nextAppointment = getNextAppointment(client);

    final timeStr = nextAppointment != null
        ? '${nextAppointment.hour.toString().padLeft(2, '0')}:'
              '${nextAppointment.minute.toString().padLeft(2, '0')}'
        : 'No upcoming';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Text(
            client.name[0],
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(client.name)),
            Text(
              timeStr,
              style: const TextStyle(color: Color.fromARGB(255, 80, 80, 80)),
            ),
          ],
        ),
        subtitle: Text('${client.age} years old, ${client.gender}'),
        trailing: Icon(Icons.circle, color: getStatusColor(client.active)),
        onTap: onTap,
      ),
    );
  }
}

/// ===== Client Detail View =====
class ClientDetailViewWidget extends StatefulWidget {
  final ClientDetailViewModel viewModel;
  final Map<String, bool> exerciseDone;
  final Map<String, StopWatchTimer> stopWatches;
  final void Function(String, bool?) onToggleDone;
  final VoidCallback? onMovesenseTap;

  const ClientDetailViewWidget({
    super.key,
    required this.viewModel,
    required this.exerciseDone,
    required this.stopWatches,
    required this.onToggleDone,
    this.onMovesenseTap,
  });

  @override
  State<ClientDetailViewWidget> createState() => _ClientDetailViewWidgetState();
}

class _ClientDetailViewWidgetState extends State<ClientDetailViewWidget> {
  late Client _client;
  late Map<String, HeartRateRecovery> _hrrResults;

  @override
  void initState() {
    super.initState();
    _client = widget.viewModel.client;
    _hrrResults = Map<String, HeartRateRecovery>.from(_client.hrrResults);
  }

  @override
  Widget build(BuildContext context) {
    final client = _client;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== Header: Avatar + Name + Status =====
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(
                  client.name[0],
                  style: const TextStyle(color: Colors.white, fontSize: 30),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // ===== Client Name =====
                        Expanded(
                          child: Text(
                            client.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        // ===== Trailing Buttons =====
                        Row(
                          mainAxisSize: MainAxisSize
                              .min, // makes the inner row wrap its children
                          children: [
                            IconButton(
                              icon: const Icon(Icons.add, size: 24),
                              onPressed: () {
                                // TODO: Handle plus button click (for adding appointments)
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, size: 24),
                              onPressed: () async {
                                final updatedClient =
                                    await Navigator.push<Client>(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            EditClientPage(client: client),
                                      ),
                                    );

                                if (updatedClient != null) {
                                  // TODO: Handle updated client (e.g., refresh view)
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Text('Status: '),
                        Icon(
                          Icons.circle,
                          color: getStatusColor(client.active),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ===== Movesense Status =====
          ListenableBuilder(
            listenable: MovesenseService().viewModel,
            builder: (context, _) {
              return MoveSenseStatusCard(
                connected: MovesenseService().viewModel.isConnected,
                heartRate: 0,
                heartRateStream: MovesenseService().viewModel.heartRateStream,
                batteryOk: true,
                batteryStream: MovesenseService().viewModel.batteryStream,
                onTap: widget.onMovesenseTap,
              );
            },
          ),
          const SizedBox(height: 16),

          // ===== Personal Info Card =====
          SizedBox(
            width: double.infinity,
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Personal Info',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Age: ${client.age}'),
                    Text('Gender: ${client.gender}'),
                    const SizedBox(height: 8),
                    const Text(
                      'Motivation:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      client.motivation.isNotEmpty
                          ? client.motivation
                          : 'No motivation notes added.',
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ===== Appointments Card =====
          SizedBox(
            width: double.infinity,
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Appointments',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (client.appointments.isEmpty)
                      const Text('No upcoming appointments')
                    else
                      ...client.appointments.map((a) {
                        final dt = DateTime.fromMillisecondsSinceEpoch(
                          a.timestamp * 1000,
                        );
                        final hour = dt.hour.toString().padLeft(2, '0');
                        final minute = dt.minute.toString().padLeft(2, '0');
                        final dateStr =
                            '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text('$dateStr $hour:$minute'),
                        );
                      }),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ===== Exercises =====
          const Text(
            'Exercises',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Column(
            children: client.exercises.map((exercise) {
              final done = widget.exerciseDone[exercise.exerciseId] ?? false;
              final stopWatch = widget.stopWatches[exercise.exerciseId];
              final hrr = _hrrResults[exercise.exerciseId];

              return SizedBox(
                width: double.infinity,
                child: Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top row: name + sets/reps or time
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                exercise.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  decoration: done
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: done ? Colors.grey : null,
                                ),
                              ),
                            ),
                            if (exercise is CountableExercise)
                              Text(
                                '${exercise.sets} sets • ${exercise.reps} reps',
                              )
                            else if (exercise is TimeableExercise)
                              Text('Time: ${exercise.time}s'),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Row: checkbox / stopwatch + heart button
                        Row(
                          children: [
                            if (exercise is CountableExercise)
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Checkbox(
                                    value: done,
                                    onChanged: (val) => widget.onToggleDone(
                                      exercise.exerciseId,
                                      val,
                                    ),
                                  ),
                                ),
                              ),
                            if (exercise is TimeableExercise &&
                                stopWatch != null)
                              Expanded(
                                child: StopwatchWidget(
                                  stopWatchTimer: stopWatch,
                                ),
                              ),

                            if (hrr != null)
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'High: ${hrr.high}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    Text(
                                      'Low: ${hrr.low}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    Text(
                                      'HRR: ${hrr.delta}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // Heart button (changes style after HRR captured)
                            Builder(
                              builder: (context) {
                                final hasHrr = hrr != null;
                                final borderRadius = BorderRadius.circular(20);
                                final borderColor =
                                    Theme.of(context).colorScheme.primary;
                                return Material(
                                  color: hasHrr
                                      ? Colors.white
                                      : Theme.of(context)
                                          .colorScheme
                                          .primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: borderRadius,
                                    side: hasHrr
                                        ? BorderSide(color: borderColor)
                                        : BorderSide.none,
                                  ),
                                  elevation: 1,
                                  child: InkWell(
                                    customBorder: RoundedRectangleBorder(
                                      borderRadius: borderRadius,
                                    ),
                                    onTap: () => _startHeartRateRecovery(
                                      context,
                                      exercise.exerciseId,
                                      exercise.name,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Icon(
                                        Icons.favorite,
                                        color: hasHrr
                                            ? const Color.fromARGB(
                                                255,
                                                210,
                                                57,
                                                62,
                                              )
                                            : Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// Collects heart rate samples for a fixed window and shows recovery stats.
  Future<void> _startHeartRateRecovery(
    BuildContext context,
    String exerciseId,
    String exerciseName,
  ) async {
    final movesense = MovesenseService().viewModel;
    final hrStream = movesense.heartRateStream;

    if (!movesense.isConnected || hrStream == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No Movesense device connected.')),
      );
      return;
    }

    const measurementDuration = Duration(seconds: 60); // standard HRR window
    final readings = <int>[];
    final timeLeft = ValueNotifier<int>(measurementDuration.inSeconds);
    final lastHr = ValueNotifier<int?>(null);

    StreamSubscription<int>? sub;
    Timer? countdown;

    // Show a blocking dialog while measuring.
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Measuring HRR for $exerciseName'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 12),
              ValueListenableBuilder<int>(
                valueListenable: timeLeft,
                builder: (_, seconds, __) => Text(
                  'Time left: ${seconds}s',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(height: 8),
              ValueListenableBuilder<int?>(
                valueListenable: lastHr,
                builder: (_, hr, __) => Text(
                  hr == null ? 'Waiting for data…' : 'Current HR: $hr',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        );
      },
    );

    sub = hrStream.listen((hr) {
      if (hr <= 0) return; // ignore invalid readings
      readings.add(hr);
      lastHr.value = hr;
    });

    countdown = Timer.periodic(const Duration(seconds: 1), (t) {
      final remaining = measurementDuration.inSeconds - t.tick;
      if (remaining >= 0) {
        timeLeft.value = remaining;
      }
      if (remaining <= 0) {
        t.cancel();
      }
    });

    await Future.delayed(measurementDuration);

    await sub.cancel();
    countdown.cancel();
    timeLeft.dispose();
    lastHr.dispose();

    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }

    if (readings.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No heart rate data captured.')),
        );
      }
      return;
    }

    final maxHr = readings.reduce(max);
    final minHr = readings.reduce(min);
    final recovery = maxHr - minHr;

    setState(() {
      _hrrResults = Map<String, HeartRateRecovery>.from(_hrrResults)
        ..[exerciseId] = HeartRateRecovery(high: maxHr, low: minHr);
      _client = _client.copyWith(hrrResults: _hrrResults);
      ClientDataService().updateClient(_client);
    });

    if (context.mounted) {
      showDialog<void>(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('Heart Rate Recovery'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Exercise: $exerciseName'),
                const SizedBox(height: 8),
                Text('Highest HR: $maxHr bpm'),
                Text('Lowest HR: $minHr bpm'),
                const SizedBox(height: 8),
                Text('Recovery (high - low): $recovery bpm'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }
}
