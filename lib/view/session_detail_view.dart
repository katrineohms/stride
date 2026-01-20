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
import '../widgets/movesense_connection_card.dart';
import '../widgets/personal_info_card.dart';
import '../widgets/executable_exercise_card.dart';

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

  Client get _client => widget.viewModel.client;

  @override
  void initState() {
    super.initState();
    widget.viewModel.attach();
    widget.viewModel.addListener(_onSessionChanged);
    _initializeExerciseState();
    
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
    setState(() {
      _initializeExerciseState();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_client.name} - Session'),
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

            // ===== Client Info =====
            PersonalInfoCard(client: _client),
            const SizedBox(height: 16),

            // ===== HR Session Controls =====
            Text(
              'Heart Rate Session',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => widget.viewModel.startSession(),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start Session'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => widget.viewModel.stopSession(),
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop Session'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
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
                onHrrTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('HRR measurement coming soon')),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}
