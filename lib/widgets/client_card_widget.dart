import 'package:flutter/material.dart';
import '../model/clients.dart';

class ClientCard extends StatelessWidget {
  // ======= Properties =======
  final Client client;
  final VoidCallback? onTap;

  const ClientCard({
    super.key,
    required this.client,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Convert Unix timestamp to DateTime
    final appointmentDateTime =
        DateTime.fromMillisecondsSinceEpoch(client.nextAppointment * 1000);

    // Format HH:MM
    final timeStr =
        '${appointmentDateTime.hour.toString().padLeft(2, '0')}:'
        '${appointmentDateTime.minute.toString().padLeft(2, '0')}';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        // ===== Avatar =====
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Text(
            client.name[0],
            style: const TextStyle(color: Colors.white),
          ),
        ),

        // ===== Title with HH:MM inline =====
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

        // ===== Subtitle =====
        subtitle: Text('${client.age} years old, ${client.gender}'),

        // ===== Status Icon =====
        trailing: Icon(
          Icons.circle,
          color: getStatusColor(client.active),
        ),

        // ===== OnTap Handler =====
        onTap: onTap,
      ),
    );
  }
}

// ===== Helper =====
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
