import 'package:flutter/material.dart';
import '../model/clients.dart';

class AppointmentFormWidget extends StatefulWidget {
  final List<Appointment> initialAppointments;
  final Function(Appointment) onCreate;
  final Function(Appointment)? onRemove;

  const AppointmentFormWidget({
    super.key,
    this.initialAppointments = const [],
    required this.onCreate,
    this.onRemove,
  });

  @override
  State<AppointmentFormWidget> createState() =>
      _AppointmentFormWidgetState();
}

class _AppointmentFormWidgetState extends State<AppointmentFormWidget> {
  late List<Appointment> _appointments;

  @override
  void initState() {
    super.initState();
    _appointments = List.from(widget.initialAppointments);
  }

  void _addAppointment() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (pickedDate == null) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime == null) return;

    final timestamp = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    ).millisecondsSinceEpoch ~/ 1000;

    final appointment = Appointment(timestamp: timestamp);

    setState(() {
      _appointments.add(appointment);
    });

    widget.onCreate(appointment);
  }

  void _removeAppointment(Appointment a) {
    setState(() {
      _appointments.remove(a);
    });

    widget.onRemove?.call(a);
  }

  String _formatTimestamp(int timestamp) {
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return
        '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

            if (_appointments.isEmpty)
              const Text('No appointments'),

            for (final a in _appointments)
              ListTile(
                title: Text(_formatTimestamp(a.timestamp)),
                trailing: IconButton(
                  icon:
                      const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeAppointment(a),
                ),
              ),

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
