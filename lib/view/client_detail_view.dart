// Packages
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Files
import '../model/_models.dart';
import '../view_model/client_detail_view_model.dart';
import '../view_model/session_detail_view_model.dart';
import '../view/movesense_connect_view.dart';
import '../view/session_detail_view.dart';

// Widgets
import '../widgets/personal_info_card.dart';
import '../widgets/movesense_connection_card.dart';
import '../widgets/exercise_template_card.dart';


/// Client detail page - overview from client list or drawer
class ClientDetailPage extends StatefulWidget {
  final ClientDetailViewModel viewModel;

  const ClientDetailPage({super.key, required this.viewModel});

  @override
  State<ClientDetailPage> createState() => _ClientDetailPageState();
}

class _ClientDetailPageState extends State<ClientDetailPage> {
  Client get _client => widget.viewModel.client;

  @override
  void initState() {
    super.initState();
    widget.viewModel.attach();
    widget.viewModel.addListener(_onClientChanged);
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_onClientChanged);
    widget.viewModel.dispose();
    super.dispose();
  }

  void _onClientChanged() {
    setState(() {});
  }

  List<Session> get _previousSessions {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return _client.sessions
        .where((s) => s.endTime != null && s.startTime < now)
        .toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
  }

  List<Session> get _upcomingSessions {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return _client.sessions
        .where((s) => s.startTime >= now && s.endTime == null)
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_client.name),
        centerTitle: true,
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
                return MovesenseConnectionCard(
                  isConnected: widget.viewModel.movesense.isConnected,
                  heartRateStream: widget.viewModel.movesense.heartRateStream,
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
            PersonalInfoCard(client: _client),
            const SizedBox(height: 16),

            // ===== Upcoming Sessions =====
            Text(
              'Upcoming Sessions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            if (_upcomingSessions.isEmpty)
              const Card(
                child: Padding(
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
              const Card(
                child: Padding(
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
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No exercise templates'),
                ),
              )
            else
              ..._client.exerciseTemplates.map((exercise) {
                return ExerciseTemplateCard(exercise: exercise);
              }),
          ],
        ),
      ),
    );
  }
}
