// Packages
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Files
import '../model/_models.dart';
import '../view_model/client_detail_view_model.dart';
import '../view_model/session_detail_view_model.dart';
import '../view/movesense_connect_view.dart';
import '../view/session_detail_view.dart';
import '../view/edit_client_view.dart';

// Widgets
import '../widgets/personal_info_card.dart';
import '../widgets/movesense_status_widget.dart';
import '../widgets/exercise_template_card.dart';

/// ============================================
/// CLIENT DETAIL PAGE
/// ============================================
/// Shows comprehensive view of a single client including:
/// - Movesense connection status
/// - Personal info (age, gender, motivation)
/// - Upcoming scheduled sessions
/// - Previous session history
/// - Exercise templates
/// - Quick start button for immediate session recording

// Client detail page - overview from client list or drawer
class ClientDetailPage extends StatefulWidget {
  final ClientDetailViewModel viewModel;

  const ClientDetailPage({super.key, required this.viewModel});

  @override
  State<ClientDetailPage> createState() => _ClientDetailPageState();
}

class _ClientDetailPageState extends State<ClientDetailPage> with WidgetsBindingObserver {
  // ======= Getters =======
  Client get _client => widget.viewModel.client;

  // ======= Lifecycle Methods =======
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.viewModel.attach();
    widget.viewModel.addListener(_onClientChanged);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      // Refresh client data when returning to this view
      widget.viewModel.refreshClient();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.viewModel.removeListener(_onClientChanged);
    widget.viewModel.dispose();
    super.dispose();
  }

  // ======= UI Event Handlers =======
  void _onClientChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  // ======= Build UI =======
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_client.name),
        centerTitle: true,
        actions: [
          MovesenseAppBarStatus(viewModel: widget.viewModel.movesense),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== Movesense Card =====
            ListenableBuilder(
              listenable: widget.viewModel.movesense,
              builder: (context, _) {
                return MoveSenseStatusCard(
                  connected: widget.viewModel.movesense.isConnected,
                  heartRate: 0,
                  heartRateStream: widget.viewModel.movesense.heartRateStream,
                  batteryOk: true,
                  batteryStream: widget.viewModel.movesense.batteryStream,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MovesenseConnectView(
                          viewModel: widget.viewModel.movesense,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 16),

            // ===== Personal Info =====
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    width: double.infinity,
                    child: PersonalInfoCard(client: _client),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ===== Upcoming Sessions =====
            Text(
              'Upcoming Sessions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            if (widget.viewModel.upcomingSessions.isEmpty)
              SizedBox(
                width: double.infinity,
                child: Card(
                  color: Theme.of(context).cardColor,
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No upcoming sessions'),
                  ),
                ),
              )
            else
              ...widget.viewModel.upcomingSessions.map((session) {
                final date = DateTime.fromMillisecondsSinceEpoch(
                  session.startTime * 1000,
                );
                return Card(
                  color: Theme.of(context).cardColor,
                  child: ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: Text(DateFormat('MMMM d, y').format(date)),
                    subtitle: Text(DateFormat('h:mm a').format(date)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SessionDetailPage(
                            viewModel: SessionDetailViewModel(
                              client: _client,
                              session: session,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await widget.viewModel.startSession();
                      if (context.mounted) {
                        // Navigate to session detail view
                        final latestClient = await widget.viewModel.getLatestClient();
                        final activeSession = widget.viewModel.sessionService.activeSession;
                        if (latestClient != null && activeSession != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SessionDetailPage(
                                viewModel: SessionDetailViewModel(
                                  client: latestClient,
                                  session: activeSession,
                                ),
                              ),
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text(
                      'Start new session',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      // Show dialog to select date/time for new session
                      final selectedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      
                      if (selectedDate != null && context.mounted) {
                        final selectedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );

                        if (selectedTime != null && context.mounted) {
                          final scheduledDateTime = DateTime(
                            selectedDate.year,
                            selectedDate.month,
                            selectedDate.day,
                            selectedTime.hour,
                            selectedTime.minute,
                          );
                          
                          final newSession = Session(
                            sessionId: DateTime.now().millisecondsSinceEpoch.toString(),
                            startTime: scheduledDateTime.millisecondsSinceEpoch ~/ 1000,
                            endTime: null,
                            hrReadings: [],
                            exercisesPerformed: [],
                            startLocationCity: '',
                          );

                          if (context.mounted) {
                            await widget.viewModel.addScheduledSession(newSession);
                            setState(() {});
                          }
                        }
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text(
                      'Schedule session',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
              ),
            ),
            const SizedBox(height: 16),

            // ===== Previous Sessions =====
            Text(
              'Previous Sessions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            if (widget.viewModel.previousSessions.isEmpty)
              SizedBox(
                width: double.infinity,
                child: Card(
                  color: Theme.of(context).cardColor,
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No previous sessions'),
                  ),
                ),
              )
            else
              ...widget.viewModel.previousSessions.map((session) {
                final date = DateTime.fromMillisecondsSinceEpoch(
                  session.startTime * 1000,
                );
                return SizedBox(
                  width: double.infinity,
                  child: Card(
                  color: Theme.of(context).cardColor,
                  child: ListTile(
                    leading: const Icon(Icons.history),
                    title: Text(DateFormat('MMMM d, y').format(date)),
                    subtitle: Text(
                      session.endTime != null
                          ? 'Duration: ${session.duration ~/ 60} min'
                          : 'In progress',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SessionDetailPage(
                            viewModel: SessionDetailViewModel(
                              client: _client,
                              session: session,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  ),
                );
              }),
            const SizedBox(height: 16),

            // ===== Exercise Templates =====
            Text(
              'Exercise Template',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            if (_client.exerciseTemplates.isEmpty)
              Card(
                color: Theme.of(context).cardColor,
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No exercise templates'),
                ),
              )
            else
              ..._client.exerciseTemplates.map((exercise) {
                return ExerciseTemplateCard(exercise: exercise);
              }),
            const SizedBox(height: 16),

            // ===== Edit Button =====
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final updated = await Navigator.push<Client>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditClientPage(client: _client),
                    ),
                  );
                  if (updated != null) {
                    await widget.viewModel.updateClient(updated);
                  }
                },
                icon: const Icon(Icons.edit),
                label: const Text('Edit Client'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
