import 'package:flutter/material.dart';
import '../../../model/clients.dart';


class ClientCard extends StatelessWidget {
  final Client client;
  final VoidCallback? onTap;

  const ClientCard({
    super.key,
    required this.client,
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
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Text(
            client.name[0],
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(client.name),
        subtitle: Text(client.age.toString() + ' years old, ' + client.gender),
        trailing: Icon(
          Icons.circle,
          color: getStatusColor(client.active),
        ),
        onTap: onTap,
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
      return Colors.grey; // fallback
  }
}

String getStatusText(int active) {
  switch (active) {
    case 0:
      return 'Active';
    case 1:
      return 'Caution';
    case 2:
      return 'Inactive';
    default:
      return 'Unknown';
  }
}

class ClientDetailPage extends StatelessWidget {
  final Client client;

  const ClientDetailPage({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(client.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${client.name}', style: const TextStyle(fontSize: 22)),
            Text('Age: ${client.age}'),
            Text('Gender: ${client.gender}'),
            Text('Status: ${getStatusText(client.active)}'),
            Text(
                'Next Appointment: ${DateTime.fromMillisecondsSinceEpoch(client.nextAppointment * 1000).toLocal()}'),
            Text('Motivation: ${client.motivation}'),
          ],
        ),
      ),
    );
  }
}