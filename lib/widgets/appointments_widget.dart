import 'package:flutter/material.dart';
import '../model/clients.dart';
import '../view_model/appointment_form_view_model.dart';

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
  late AppointmentFormViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = AppointmentFormViewModel();
    viewModel.initialize(widget.initialAppointments);
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

    final appointment = viewModel.createAppointment(pickedDate, pickedTime);

    setState(() {
      viewModel.addAppointment(appointment);
    });

    widget.onCreate(appointment);
  }

  void _removeAppointment(Appointment a) {
    setState(() {
      viewModel.removeAppointment(a);
    });

    widget.onRemove?.call(a);
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

            if (viewModel.appointments.isEmpty)
              const Text('No appointments'),

            for (final a in viewModel.appointments)
              ListTile(
                title: Text(viewModel.formatTimestamp(a.timestamp)),
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
