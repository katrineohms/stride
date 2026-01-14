import '../model/clients.dart';
import 'package:flutter/material.dart';

class ClientDetailViewModel {
  final Client client;

  ClientDetailViewModel({required this.client});

  // Display-friendly status color
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

  // Convert timestamp to readable DateTime
  String get nextAppointmentFormatted {
    final dt =
        DateTime.fromMillisecondsSinceEpoch(client.nextAppointment * 1000);
    return '${dt.toLocal()}'.split(' ')[0]; // Just YYYY-MM-DD
  }
}
