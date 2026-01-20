// Packages
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

// Files
import '../model/_models.dart';
import '../view_model/session_detail_view_model.dart';
import '../view_model/widgets_view_model/ui_event.dart';
import '../view/movesense_connect_view.dart';

// Widgets
import '../widgets/movesense_status_widget.dart';
import '../widgets/personal_info_card.dart';
import '../widgets/executable_exercise_card.dart';
import '../widgets/session_graph_card.dart';

/// Session detail page - for executing a specific session from calendar
class SessionDetailPage extends StatefulWidget {
  final SessionDetailViewModel viewModel;

  const SessionDetailPage({super.key, required this.viewModel});

  @override
  State<SessionDetailPage> createState() => _SessionDetailPageState();
}

class _SessionDetailPageState extends State<SessionDetailPage> {
  final Map<String, bool> _exerciseDone = {};
  final Map<String, StopWatchTimer> _stopWatches = {};
  late StreamSubscription<UiEvent> _eventSub;
  Timer? _ticker;

  Client get _client => widget.viewModel.client;

  @override
  void initState() {
    super.initState();
    widget.viewModel.attach();
    widget.viewModel.addListener(_onSessionChanged);
    _initializeExerciseState();
    _startTicker();
    
    _eventSub = widget.viewModel.events.stream.listen((event) {
      if (!mounted) return;
      if (event is SnackBarEvent) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(event.message),
            backgroundColor:
                event.isError ? Theme.of(context).colorScheme.error : null,
          ),
        );
      }
    });
  }

  void _initializeExerciseState() {
    _exerciseDone.clear();
    for (final ex in _stopWatches.values) {
      ex.dispose();
    }
    _stopWatches.clear();

    // Use exercises from session's template (client's exerciseTemplates)
    for (final ex in _client.exerciseTemplates) {
      if (ex is CountableExercise) {
        _exerciseDone[ex.exerciseId] = false;
      } else if (ex is TimeableExercise) {
        _stopWatches[ex.exerciseId] = StopWatchTimer(
          mode: StopWatchMode.countDown,
          presetMillisecond: ex.time * 1000,
        );
      }
    }
  }

  @override
  void dispose() {
    for (final timer in _stopWatches.values) {
      timer.dispose();
    }
    _ticker?.cancel();
    _eventSub.cancel();
    widget.viewModel.removeListener(_onSessionChanged);
    widget.viewModel.dispose();
    super.dispose();
  }

  void _toggleDone(String exerciseId, bool? value) {
    setState(() {
      _exerciseDone[exerciseId] = value ?? false;
    });
  }

  void _onSessionChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        _ticker?.cancel();
        return;
      }
      if (widget.viewModel.isActiveForClient) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isActive = widget.viewModel.isActiveForClient;
    final latestSession = widget.viewModel.activeSession;

    return Scaffold(
      appBar: AppBar(
        title: Text('${_client.name} - Session'),
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

            // ===== Client Info =====
            SizedBox(
              width: double.infinity,
              child: PersonalInfoCard(client: _client),
            ),
            const SizedBox(height: 16),

            // ===== Session Timer =====
            if (isActive)
              Center(
                child: Column(
                  children: [
                    const Text(
                      'Elapsed Time',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDuration(widget.viewModel.liveDuration),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            if (isActive)
              const SizedBox(height: 16),

            // ===== HR Session Controls =====
            if (!(isActive == false && latestSession.hrReadings.isNotEmpty))
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (isActive) {
                      await widget.viewModel.stopSession();
                      // Refresh session from storage to ensure HRR data is loaded
                      widget.viewModel.attach();
                    } else {
                      await widget.viewModel.startSession();
                    }
                    if (mounted) setState(() {});
                  },
                  icon: Icon(isActive ? Icons.stop : Icons.play_arrow),
                  label: Text(isActive ? 'Stop Session' : 'Start Session'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isActive ? Colors.red : null,
                    foregroundColor: isActive ? Colors.white : null,
                  ),
                ),
              ),
            if (!(isActive == false && latestSession.hrReadings.isNotEmpty))
              const SizedBox(height: 16),

            // Session graph (only after session ends and has data)
            if (!isActive && latestSession.hrReadings.isNotEmpty)
              SessionGraphCard(session: latestSession),

            if (!isActive && latestSession.hrReadings.isNotEmpty)
              const SizedBox(height: 16),

            // ===== Exercises =====
            Text(
              'Exercises',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            ..._client.exerciseTemplates.map((exercise) {
              return ExecutableExerciseCard(
                exercise: exercise,
                isDone: _exerciseDone[exercise.exerciseId] ?? false,
                stopWatch: _stopWatches[exercise.exerciseId],
                onDoneChanged: (value) => _toggleDone(exercise.exerciseId, value),
              );
            }),
            const SizedBox(height: 16),

            // ===== Delete Session Button =====
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: latestSession.hrReadings.isNotEmpty
                    ? () {
                        showDialog<void>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Delete Session'),
                            content: const Text('Are you sure you want to delete this session?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  widget.viewModel.deleteLatestSession();
                                  Navigator.pop(ctx);
                                  Navigator.pop(context);
                                },
                                child: const Text('Delete', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                      }
                    : null,
                icon: const Icon(Icons.delete),
                label: const Text('Delete Session'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: latestSession.hrReadings.isNotEmpty ? Colors.red : Colors.grey,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}

String _formatDuration(Duration? duration) {
  if (duration == null) return '--';
  final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  final hours = duration.inHours;
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  if (hours > 0) {
    return '${hours.toString().padLeft(2, '0')}:$minutes:$seconds';
  }
  return '$minutes:$seconds';
}
