// Packages
import 'package:flutter/material.dart';

// Files
import '../model/_models.dart';

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

/// ===== Helper to get next upcoming session time =====
DateTime? getNextSessionTime(Client client) {
  final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  final futureSessions = client.sessions
      .where((s) => s.startTime >= now && s.endTime == null)
      .toList();

  if (futureSessions.isEmpty) return null;

  futureSessions.sort((a, b) => a.startTime.compareTo(b.startTime));
  return DateTime.fromMillisecondsSinceEpoch(
    futureSessions.first.startTime * 1000,
  );
}

/// ===== Client Card =====
class ClientCard extends StatelessWidget {
  final Client client;
  final VoidCallback? onTap;

  const ClientCard({super.key, required this.client, this.onTap});

  @override
  Widget build(BuildContext context) {
      final nextSession = getNextSessionTime(client);

      final timeStr = nextSession != null
      ? '${nextSession.hour.toString().padLeft(2, '0')}:'
        '${nextSession.minute.toString().padLeft(2, '0')}'
      : 'No upcoming';

    return Card(
      color: Theme.of(context).cardColor,
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

