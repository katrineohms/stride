import 'package:flutter/material.dart';
import '../model/clients.dart';
import '../widgets/stop_watch_timer_widget.dart';
import '../widgets/movesense_status_widget.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import '../view/client_card_view.dart';

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
  final futureAppointments =
      client.appointments.where((a) => a.timestamp >= now).toList();

  if (futureAppointments.isEmpty) return null;

  futureAppointments.sort((a, b) => a.timestamp.compareTo(b.timestamp));
  return DateTime.fromMillisecondsSinceEpoch(futureAppointments.first.timestamp * 1000);
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
              style: const TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
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
class ClientDetailViewWidget extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final client = viewModel.client;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== Header =====
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    client.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Text('Status: '),
                      Icon(Icons.circle, color: viewModel.statusColor),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),

          // ===== Movesense Status =====
          MoveSenseStatusCard(
            connected: true,
            heartRate: 72,
            batteryOk: true,
            onTap: onMovesenseTap,
          ),
          const SizedBox(height: 4),

          // ===== Client Info Card =====
          Card(
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
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text('Age: ${client.age}'),
                  Text('Gender: ${client.gender}'),
                  const SizedBox(height: 8),

                  // ===== Appointments =====
                  const Text(
                    'Appointments:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  if (client.appointments.isEmpty)
                    const Text('No upcoming appointments')
                  else
                    ...client.appointments.map((a) {
                      final dt = DateTime.fromMillisecondsSinceEpoch(a.timestamp * 1000);
                      final hour = dt.hour.toString().padLeft(2, '0');
                      final minute = dt.minute.toString().padLeft(2, '0');
                      final dateStr =
                          '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
                      return Text('$dateStr $hour:$minute');
                    }).toList(),
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
          const SizedBox(height: 16),

          // ===== Exercises =====
          const Text(
            'Exercises',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Column(
            children: client.exercises.map((exercise) {
              final done = exerciseDone[exercise.exerciseId] ?? false;
              final stopWatch = stopWatches[exercise.exerciseId];

              return Card(
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
                            Text('${exercise.sets} sets • ${exercise.reps} reps')
                          else if (exercise is TimeableExercise)
                            Text('Time: ${exercise.time}s'),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Second row: checkbox or stopwatch
                      if (exercise is CountableExercise)
                        Row(
                          children: [
                            Checkbox(
                              value: done,
                              onChanged: (val) =>
                                  onToggleDone(exercise.exerciseId, val),
                            ),
                          ],
                        )
                      else if (exercise is TimeableExercise && stopWatch != null)
                        Row(
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: StopwatchWidget(stopWatchTimer: stopWatch),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
