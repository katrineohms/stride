import '../model/clients.dart';
import 'package:flutter/material.dart';

/// ViewModel for the Client Detail Page
class ClientDetailViewModel {
  final Client client;

  ClientDetailViewModel({required this.client});

  // ===== Client status color =====
  Color get statusColor {
    switch (client.active) {
      case 0:
        return Colors.green;   // Active
      case 1:
        return Colors.yellow;  // Caution
      case 2:
        return Colors.red;     // Inactive
      default:
        return Colors.grey;    // Unknown
    }
  }

  // ===== Next Appointment =====
  /// Returns the soonest future appointment, or null if none
  Appointment? get nextAppointment {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    // Filter only future appointments
    final futureAppointments = client.appointments
        .where((a) => a.timestamp >= now)
        .toList();

    if (futureAppointments.isEmpty) return null;

    // Sort by timestamp ascending
    futureAppointments.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return futureAppointments.first;
  }

  /// Formatted string for the next appointment (YYYY-MM-DD HH:MM)
  String get nextAppointmentFormatted {
    final appointment = nextAppointment;
    if (appointment == null) return 'No upcoming appointment';

    final dt = DateTime.fromMillisecondsSinceEpoch(appointment.timestamp * 1000);
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    final dateStr = '${dt.toLocal().toIso8601String().split('T')[0]}';

    return '$dateStr $hour:$minute';
  }

  /// Exercises remain tied to the client
  List<Exercise> get exercises => client.exercises;
}
