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

  // ======= Build UI =======
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        // ======= Avatar =======
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Text(
            client.name[0],
            style: const TextStyle(color: Colors.white),
          ),
        ),

        // ======= Title & Subtitle =======
        title: Text(client.name),
        subtitle: Text('${client.age} years old, ${client.gender}'),

        // ======= Status Icon =======
        trailing: Icon(
          Icons.circle,
          color: getStatusColor(client.active),
        ),

        // ======= OnTap Handler =======
        onTap: onTap, // navigation handled outside
      ),
    );
  }
}

// ======= Helper Methods =======
/// Convert client activity to color
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

/// Convert client activity to text
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
