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
