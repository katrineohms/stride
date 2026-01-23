// Packages
import 'package:flutter/material.dart';

// Files
import '../model/_models.dart';

/// Personal information card widget - displays client details
class PersonalInfoCard extends StatelessWidget {
  final Client client;

  const PersonalInfoCard({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).cardColor,
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
              'Personal Information',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text('Name: ${client.name}'),
            Text('Age: ${client.age}'),
            Text('Gender: ${client.gender}'),
            if (client.motivation.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                'Motivation:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(client.motivation),
            ],
          ],
        ),
      ),
    );
  }
}
