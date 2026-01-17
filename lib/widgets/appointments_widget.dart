import 'package:flutter/material.dart';
import '../model/clients.dart';

class AppointmentFormWidget extends StatefulWidget {
  final Function(Appointment) onCreate;

  const AppointmentFormWidget({super.key, required this.onCreate});

  @override
  State<AppointmentFormWidget> createState() => _AppointmentFormWidgetState();
}

class _AppointmentFormWidgetState extends State<AppointmentFormWidget> {
  final List<Appointment> _addedAppointments = [];

  void _addAppointment() async {
    // Pick a date
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (pickedDate == null) return;

    // Pick a time
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime == null) return;

    // Combine date + time to timestamp
    final timestamp = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    ).millisecondsSinceEpoch ~/ 1000;

    final newAppointment = Appointment(timestamp: timestamp);

    setState(() {
      _addedAppointments.add(newAppointment);
    });

    // Pass to parent viewModel (CreateClientPage)
    widget.onCreate(newAppointment);
  }

  void _removeAppointment(Appointment a) {
    setState(() {
      _addedAppointments.remove(a);
    });
  }

  String _formatTimestamp(int timestamp) {
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    final date = '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    final time = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    return '$date $time';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Appointments',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // List of added appointments
            if (_addedAppointments.isNotEmpty)
              Column(
                children: _addedAppointments.map((a) {
                  return ListTile(
                    title: Text(_formatTimestamp(a.timestamp)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeAppointment(a),
                    ),
                  );
                }).toList(),
              ),

            // Add appointment button
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: _addAppointment,
                icon: const Icon(Icons.add),
                label: const Text('Add Appointment'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
