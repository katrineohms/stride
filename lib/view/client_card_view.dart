import 'package:flutter/material.dart';
import '../model/clients.dart';
//import '../view/widgets/client_card_widget.dart'; // optional if you want status helpers

class ClientDetailPage extends StatelessWidget {
  final Client client;

  const ClientDetailPage({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
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
            // Header: avatar and status
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
                          color: getStatusColor(client.active),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Client details
            Text('Age: ${client.age}'),
            const SizedBox(height: 8),
            Text('Gender: ${client.gender}'),
            const SizedBox(height: 8),
            Text(
              'Next Appointment: ${DateTime.fromMillisecondsSinceEpoch(client.nextAppointment * 1000).toLocal()}',
            ),
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
          ],
        ),
      ),
    );
  }
}

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
