import 'package:flutter/material.dart';
import '../model/clients.dart';

/// ViewModel for client details
class ClientDetailViewModel {
  final Client client;

  ClientDetailViewModel({required this.client});

  /// Status color based on client activity
  Color get statusColor {
    switch (client.active) {
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

  /// Formatted next appointment date
  String get nextAppointmentFormatted {
    final dt =
        DateTime.fromMillisecondsSinceEpoch(client.nextAppointment * 1000);
    return '${dt.toLocal()}'.split(' ')[0]; // YYYY-MM-DD
  }

  /// Client exercises
  List<Exercise> get exercises => client.exercises;
}

/// Client detail page UI (stateful so we can check off exercises)
class ClientDetailPage extends StatefulWidget {
  final ClientDetailViewModel viewModel;

  const ClientDetailPage({super.key, required this.viewModel});

  @override
  State<ClientDetailPage> createState() => _ClientDetailPageState();
}

class _ClientDetailPageState extends State<ClientDetailPage> {
  // Track done state for countable exercises by exerciseId
  final Map<String, bool> _exerciseDone = {};

  @override
  void initState() {
    super.initState();
    // initialize map (default false)
    for (final ex in widget.viewModel.client.exercises) {
      _exerciseDone[ex.exerciseId] = _exerciseDone[ex.exerciseId] ?? false;
    }
  }

  void _toggleDone(String exerciseId, bool? value) {
    setState(() {
      _exerciseDone[exerciseId] = value ?? false;
    });
    // OPTIONAL: persist this change (e.g., update a DB or viewModel) if desired.
  }

  @override
  Widget build(BuildContext context) {
    final client = widget.viewModel.client;

    return Scaffold(
      appBar: AppBar(
        title: Text(client.name),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Avatar and Status
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
                        Icon(
                          Icons.circle,
                          color: widget.viewModel.statusColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Client Info
            Text('Age: ${client.age}'),
            const SizedBox(height: 8),
            Text('Gender: ${client.gender}'),
            const SizedBox(height: 8),
            Text('Next Appointment: ${widget.viewModel.nextAppointmentFormatted}'),
            const SizedBox(height: 16),

            // Motivation
            const Text(
              'Motivation:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(client.motivation.isNotEmpty
                ? client.motivation
                : 'No motivation notes added.'),

            const SizedBox(height: 16),
            const Text(
              'Exercises:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),

            // Exercises list
            Column(
              children: widget.viewModel.client.exercises.map((exercise) {
                final done = _exerciseDone[exercise.exerciseId] ?? false;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    // leading: checkbox for countable, timer icon for timed
                    leading: exercise.isCountable
                        ? Checkbox(
                            value: done,
                            onChanged: (val) => _toggleDone(exercise.exerciseId, val),
                          )
                        : const Icon(Icons.timer, color: Colors.orange),

                    title: Text(
                      exercise.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: done ? TextDecoration.lineThrough : null,
                        color: done ? Colors.grey : null,
                      ),
                    ),

                    // Subtitle: show sets/reps or time depending on type
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (exercise.isCountable) ...[
                          Text('Sets: ${exercise.sets}'),
                          Text('Reps: ${exercise.reps}'),
                        ] else ...[
                          Text('Time: ${exercise.time}s'),
                        ]
                      ],
                    ),

                    // optional: show trailing icon or actions
                    // trailing: Icon(Icons.more_horiz),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
