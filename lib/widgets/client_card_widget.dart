// lib/widgets/client_card_widget.dart
import 'package:flutter/material.dart';
import '../model/clients.dart';

class ClientCardWidget extends StatelessWidget {
  final Client client;
  final VoidCallback? onTap;

  const ClientCardWidget({super.key, required this.client, this.onTap});

  @override
  Widget build(BuildContext context) {
    final movesenseLabel =
        (client.movesenseDeviceName != null && client.movesenseDeviceName!.trim().isNotEmpty)
            ? client.movesenseDeviceName!
            : client.movesenseDeviceId;

    return Card(
      child: ListTile(
        onTap: onTap,
        title: Text(client.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Age: ${client.age}  •  Gender: ${client.gender}'),
            const SizedBox(height: 4),
            Text(movesenseLabel == null ? 'Movesense: Not set' : 'Movesense: $movesenseLabel'),
          ],
        ),
      ),
    );
  }
}