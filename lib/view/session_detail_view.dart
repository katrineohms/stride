// Packages
import 'dart:async';
import 'dart:math';
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
    setState(() {});
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (widget.viewModel.isActiveForClient) {
        setState(() {});
      }
    });
  }

  /// Collects heart rate samples for a fixed window and shows recovery stats.
  Future<void> _startHeartRateRecovery(
    BuildContext context,
    String exerciseId,
    String exerciseName,
  ) async {
    final movesense = widget.viewModel.movesense;
    final hrStream = movesense.heartRateStream;

    if (!movesense.isConnected || hrStream == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No Movesense device connected.')),
      );
      return;
    }

    const measurementDuration = Duration(seconds: 60);
    final readings = <int>[];
    final timeLeft = ValueNotifier<int>(measurementDuration.inSeconds);
    final lastHr = ValueNotifier<int?>(null);

    StreamSubscription<int>? sub;
    Timer? countdown;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Measuring HRR for $exerciseName'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 12),
              ValueListenableBuilder<int>(
                valueListenable: timeLeft,
                builder: (_, seconds, _) => Text(
                  'Time left: ${seconds}s',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(height: 8),
              ValueListenableBuilder<int?>(
                valueListenable: lastHr,
                builder: (_, hr, _) => Text(
                  hr == null ? 'Waiting for data…' : 'Current HR: $hr',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        );
      },
    );

    sub = hrStream.listen((hr) {
      if (hr <= 0) return;
      readings.add(hr);
      lastHr.value = hr;
    });

    countdown = Timer.periodic(const Duration(seconds: 1), (t) {
      final remaining = measurementDuration.inSeconds - t.tick;
      if (remaining >= 0) {
        timeLeft.value = remaining;
      }
      if (remaining <= 0) {
        t.cancel();
      }
    });

    await Future.delayed(measurementDuration);

    await sub.cancel();
    countdown.cancel();
    timeLeft.dispose();
    lastHr.dispose();

    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }

    if (readings.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No heart rate data captured.')),
        );
      }
      return;
    }

    final maxHr = readings.reduce(max);
    final minHr = readings.reduce(min);
    final recovery = maxHr - minHr;

    await widget.viewModel.saveHrrResult(
      exerciseId,
      HeartRateRecovery(high: maxHr, low: minHr),
    );

    if (mounted) {
      setState(() {});
    }

    if (context.mounted) {
      showDialog<void>(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('Heart Rate Recovery'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Exercise: $exerciseName'),
                const SizedBox(height: 8),
                Text('Highest HR: $maxHr bpm'),
                Text('Lowest HR: $minHr bpm'),
                const SizedBox(height: 8),
                Text('Recovery (high - low): $recovery bpm'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isActive = widget.viewModel.isActiveForClient;
    final latestSession = widget.viewModel.session;

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
            SizedBox(
              width: double.infinity,
              child: PersonalInfoCard(client: _client),
            ),
            const SizedBox(height: 16),

            // ===== HR Session Controls =====
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  if (isActive) {
                    await widget.viewModel.stopSession();
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
              final hrr = latestSession.hrrResults[exercise.exerciseId];
              return ExecutableExerciseCard(
                exercise: exercise,
                isDone: _exerciseDone[exercise.exerciseId] ?? false,
                stopWatch: _stopWatches[exercise.exerciseId],
                onDoneChanged: (value) => _toggleDone(exercise.exerciseId, value),
                onHrrTap: () => _startHeartRateRecovery(
                  context,
                  exercise.exerciseId,
                  exercise.name,
                ),
                hrr: hrr,
              );
            }),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
