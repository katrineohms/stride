import 'package:flutter/material.dart';
import '../model/clients.dart';
import '../view_model/appointment_form_view_model.dart';

// ============= SMART WIDGET (Container) =============
/// Manages appointment form logic and state
class AppointmentFormWidget extends StatefulWidget {
  final AppointmentFormViewModel viewModel;
  final List<Appointment> initialAppointments;
  final Function(Appointment) onCreate;
  final Function(Appointment)? onRemove;

  const AppointmentFormWidget({
    super.key,
    required this.viewModel,
    this.initialAppointments = const [],
    required this.onCreate,
    this.onRemove,
  });

  @override
  State<AppointmentFormWidget> createState() =>
      _AppointmentFormWidgetState();
}

class _AppointmentFormWidgetState extends State<AppointmentFormWidget> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.initialize(widget.initialAppointments);
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

    final appointment = widget.viewModel.createAppointment(pickedDate, pickedTime);

    setState(() {
      widget.viewModel.addAppointment(appointment);
    });

    widget.onCreate(appointment);
  }

  void _removeAppointment(Appointment a) {
    setState(() {
      widget.viewModel.removeAppointment(a);
    });

    widget.onRemove?.call(a);
  }

  @override
  Widget build(BuildContext context) {
    // Pass state and callbacks to dumb view widget
    return _AppointmentFormView(
      appointments: widget.viewModel.appointments,
      onAddAppointment: _addAppointment,
      onRemoveAppointment: _removeAppointment,
      formatTimestamp: widget.viewModel.formatTimestamp,
    );
  }
}

// ============= DUMB WIDGET (Presentational) =============
/// Pure UI widget - receives all data as parameters, no business logic
class _AppointmentFormView extends StatelessWidget {
  final List<Appointment> appointments;
  final VoidCallback onAddAppointment;
  final Function(Appointment) onRemoveAppointment;
  final String Function(int) formatTimestamp;

  const _AppointmentFormView({
    required this.appointments,
    required this.onAddAppointment,
    required this.onRemoveAppointment,
    required this.formatTimestamp,
  });

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

            if (appointments.isEmpty)
              const Text('No appointments'),

            for (final a in appointments)
              ListTile(
                title: Text(formatTimestamp(a.timestamp)),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => onRemoveAppointment(a),
                ),
              ),

            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: onAddAppointment,
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
