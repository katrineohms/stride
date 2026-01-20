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


/// Client detail page - overview from client list or drawer
class ClientDetailPage extends StatefulWidget {
  final ClientDetailViewModel viewModel;

  const ClientDetailPage({super.key, required this.viewModel});

  @override
  State<ClientDetailPage> createState() => _ClientDetailPageState();
}

class _ClientDetailPageState extends State<ClientDetailPage> with WidgetsBindingObserver {
  Client get _client => widget.viewModel.client;

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

  void _onClientChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  List<Session> get _previousSessions {
    return _client.sessions
        .where((s) => s.endTime != null)
        .toList()
      ..sort((a, b) => b.endTime!.compareTo(a.endTime!));
  }

  List<Session> get _upcomingSessions {
    return _client.sessions
        .where((s) => s.endTime == null)
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_client.name),
        centerTitle: true,
        actions: [
          ListenableBuilder(
            listenable: widget.viewModel.movesense,
            builder: (context, _) {
              return MovesenseStatusIcon(
                connected: widget.viewModel.movesense.isConnected,
                heartRate: 0,
                heartRateStream: widget.viewModel.movesense.heartRateStream,
              );
            },
          ),
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
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'Edit client',
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
            if (_upcomingSessions.isEmpty)
              Card(
                color: Theme.of(context).cardColor,
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No upcoming sessions'),
                ),
              )
            else
              ..._upcomingSessions.map((session) {
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
            const SizedBox(height: 16),

            // ===== Previous Sessions =====
            Text(
              'Previous Sessions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            if (_previousSessions.isEmpty)
              Card(
                color: Theme.of(context).cardColor,
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No previous sessions'),
                ),
              )
            else
              ..._previousSessions.take(5).map((session) {
                final date = DateTime.fromMillisecondsSinceEpoch(
                  session.startTime * 1000,
                );
                return Card(
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
                );
              }),
            const SizedBox(height: 16),

            // ===== Exercise Templates =====
            Text(
              'Exercise Templates',
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
              const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
