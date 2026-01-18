import 'package:flutter/material.dart';
import '../model/clients.dart';
import '../widgets/stop_watch_timer_widget.dart';
import '../widgets/movesense_status_widget.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import '../view/client_card_view.dart';
import '../view/edit_client_view.dart';

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
          MoveSenseStatusCard(
            connected: true,
            heartRate: 72,
            batteryOk: true,
            onTap: onMovesenseTap,
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
              final done = exerciseDone[exercise.exerciseId] ?? false;
              final stopWatch = stopWatches[exercise.exerciseId];

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

                        // Checkbox or stopwatch
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
                        else if (exercise is TimeableExercise &&
                            stopWatch != null)
                          Row(
                            children: [
                              Icon(
                                Icons.timer_outlined,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: StopwatchWidget(
                                  stopWatchTimer: stopWatch,
                                ),
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
}
