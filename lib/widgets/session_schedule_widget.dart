// Packages
import 'package:flutter/material.dart';

// Files
import '../model/_models.dart';
import '../view_model/widgets_view_model/session_schedule_view_model.dart';

/// Session scheduling widget 
class SessionScheduleWidget extends StatefulWidget {
  final SessionScheduleViewModel viewModel;
  final List<Session> initialSessions;
  final void Function(Session) onCreate;
  final void Function(Session)? onRemove;

  const SessionScheduleWidget({
    super.key,
    required this.viewModel,
    this.initialSessions = const [],
    required this.onCreate,
    this.onRemove,
  });

  @override
  State<SessionScheduleWidget> createState() => _SessionScheduleWidgetState();
}

class _SessionScheduleWidgetState extends State<SessionScheduleWidget> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.initialize(widget.initialSessions);
  }

  Future<void> _addSession() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (!mounted || pickedDate == null) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (!mounted || pickedTime == null) return;

    final session = widget.viewModel.createScheduledSession(pickedDate, pickedTime);

    setState(() {
      widget.viewModel.addSession(session);
    });

    widget.onCreate(session);
  }

  void _removeSession(Session session) {
    setState(() {
      widget.viewModel.removeSession(session);
    });

    widget.onRemove?.call(session);
  }

  @override
  Widget build(BuildContext context) {
    return _SessionScheduleView(
      sessions: widget.viewModel.sessions,
      onAddSession: _addSession,
      onRemoveSession: _removeSession,
      formatTimestamp: widget.viewModel.formatTimestamp,
    );
  }
}

/// Stateless UI portion
class _SessionScheduleView extends StatelessWidget {
  final List<Session> sessions;
  final VoidCallback onAddSession;
  final void Function(Session) onRemoveSession;
  final String Function(int) formatTimestamp;

  const _SessionScheduleView({
    required this.sessions,
    required this.onAddSession,
    required this.onRemoveSession,
    required this.formatTimestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).cardColor,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Scheduled Sessions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (sessions.isEmpty)
              const Text('No sessions scheduled'),
            for (final s in sessions)
              ListTile(
                title: Text(formatTimestamp(s.startTime)),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => onRemoveSession(s),
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: onAddSession,
                icon: const Icon(Icons.add),
                label: const Text('Add Session'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
