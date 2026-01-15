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

/// Client detail page UI
class ClientDetailPage extends StatelessWidget {
  final ClientDetailViewModel viewModel;

  const ClientDetailPage({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final client = viewModel.client;

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
                          color: viewModel.statusColor,
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
            Text('Next Appointment: ${viewModel.nextAppointmentFormatted}'),
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
            Text(
              'Exercises:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Column(
              children: viewModel.client.exercises.map((exercise) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.fitness_center, color: Colors.green),
                    title: Text(
                      exercise.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (exercise.sets > 0) Text('Sets: ${exercise.sets}'),
                        if (exercise.reps > 0) Text('Reps: ${exercise.reps}'),
                        if (exercise.time > 0) Text('Time: ${exercise.time}s'),
                      ],
                    ),
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
