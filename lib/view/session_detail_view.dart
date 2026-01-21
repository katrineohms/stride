// Packages
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

// Files
import '../model/_models.dart';
import '../view_model/session_detail_view_model.dart';
import '../view_model/client_detail_view_model.dart';
import '../view_model/widgets_view_model/ui_event.dart';
import '../view/movesense_connect_view.dart';
import '../view/client_detail_view.dart';
import '../view_model/widgets_view_model/exercise_form_view_model.dart';

// Widgets
import '../widgets/movesense_status_widget.dart';
import '../widgets/personal_info_card.dart';
import '../widgets/executable_exercise_card.dart';
import '../widgets/session_graph_card.dart';
import '../widgets/create_exercise_widget.dart';
import '../widgets/exercise_template_card.dart';

/// ============================================
/// SESSION DETAIL PAGE
/// ============================================
/// Drives a single training session workflow:
/// - Shows client info and Movesense connection status
/// - Starts/stops heart-rate recording with a live timer
/// - Displays summary and graph after completion
/// - Lists client exercise templates with execution controls
/// - Allows deleting the last completed session
///
/// Notes:
/// - Keeps the screen awake during an active session (WakelockPlus)
/// - Uses `SessionDetailViewModel` for state and background tasks
/// - Navigates back to the client detail view after stopping a session
class SessionDetailPage extends StatefulWidget {
  final SessionDetailViewModel viewModel;

  const SessionDetailPage({super.key, required this.viewModel});

  @override
  State<SessionDetailPage> createState() => _SessionDetailPageState();
}

class _SessionDetailPageState extends State<SessionDetailPage> {
  // ======= State =======
  /// Tracks exercise completion and countdown timers for time-based exercises.
  final Map<String, StopWatchTimer> _stopWatches = {};
  late StreamSubscription<UiEvent> _eventSub;
  Session? _displaySession;
  bool _isEditingExercises = false;
  final ExerciseFormViewModel _exerciseFormViewModel = ExerciseFormViewModel();
  List<Exercise> _sessionExercises = [];

  Client get _client => widget.viewModel.client;

  @override
  void initState() {
    super.initState();
    // ======= Lifecycle: initState =======
    /// Prepare UI + background behavior and subscribe to ViewModel events.
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
    /// Initialize per-exercise UI state and create timers for timeable ones.
    for (final ex in _stopWatches.values) {
      ex.dispose();
    }
    _stopWatches.clear();

    // Get session exercises - use exercisesPerformed if set, otherwise use client templates
    final displaySession = _displaySession ?? widget.viewModel.activeSession;
    _sessionExercises = displaySession.exercisesPerformed.isNotEmpty
        ? List.from(displaySession.exercisesPerformed)
        : List.from(_client.exerciseTemplates);

    // Create timers for timeable exercises
    for (final ex in _sessionExercises) {
      if (ex is TimeableExercise) {
        _stopWatches[ex.exerciseId] = StopWatchTimer(
          mode: StopWatchMode.countDown,
          presetMillisecond: ex.time * 1000,
        );
      }
    }
  }

  @override
  void dispose() {
    // ======= Lifecycle: dispose =======
    /// Clean up timers, subscriptions, listeners.
    for (final timer in _stopWatches.values) {
      timer.dispose();
    }
    _eventSub.cancel();
    widget.viewModel.removeListener(_onSessionChanged);
    widget.viewModel.dispose();
    super.dispose();
  }

  void _onSessionChanged() {
    /// Refresh the UI when the ViewModel notifies of changes.
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // ======= Build UI =======
    /// Resolve session state used across child sections.
    final isActive = widget.viewModel.isActiveForClient;
    final displaySession = _displaySession ?? widget.viewModel.activeSession;

    return Scaffold(
      // ======= App Bar =======
      /// Title includes client name; actions show Movesense realtime status icon
      appBar: AppBar(
        title: Text('${_client.name} - Session'),
        centerTitle: true,
        actions: [
          MovesenseAppBarStatus(viewModel: widget.viewModel.movesense),
        ],
      ),
      // ======= Body =======
      /// Main content: connection card, client info, controls, summary, exercises
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== Movesense Card =====
            /// Tap to open Movesense connection screen and manage pairing/connection
            /// Only visible when session is not completed (no HR data recorded yet)
            if (!(isActive == false && displaySession.hrReadings.isNotEmpty))
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
            if (!(isActive == false && displaySession.hrReadings.isNotEmpty))
              const SizedBox(height: 16),

            // ===== Client Info =====
            /// Non-editable snapshot of the client’s personal information
            SizedBox(
              width: double.infinity,
              child: PersonalInfoCard(client: _client),
            ),
            const SizedBox(height: 16),

            // ===== Session Timer =====
            /// Visible only during an active session; updates each second
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
            /// Start/Stop button; on stop, navigates to refreshed client detail view
            if (!(isActive == false && displaySession.hrReadings.isNotEmpty))
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (isActive) {
                      await widget.viewModel.stopSession();
                      // Refresh client data with the newly completed session
                      final updatedClient = await widget.viewModel.getLatestClient();
                      if (!context.mounted) return;
                      if (updatedClient != null) {
                        // Navigate to client detail view
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ClientDetailPage(
                              viewModel: ClientDetailViewModel(client: updatedClient),
                            ),
                          ),
                        );
                      }
                    } else {
                      await widget.viewModel.startSession();
                      if (mounted) setState(() {});
                    }
                  },
                  icon: Icon(isActive ? Icons.stop : Icons.play_arrow),
                  label: Text(isActive ? 'Stop Session' : 'Start Session'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isActive ? Colors.red : null,
                    foregroundColor: isActive ? Colors.white : null,
                  ),
                ),
              ),
            if (!(isActive == false && displaySession.hrReadings.isNotEmpty))
              const SizedBox(height: 16),

            // ===== Session Summary =====
            /// Renders only when a session has ended and recorded HR data exists
            if (!isActive && displaySession.hrReadings.isNotEmpty) ...[
              SizedBox(
                width: double.infinity,
                child: Card(
                  color: Theme.of(context).cardColor,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Session Completed',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Scheduled: ${DateFormat('MMMM d, y - HH:mm').format(DateTime.fromMillisecondsSinceEpoch(displaySession.startTime * 1000))}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Duration: ${_formatHm(displaySession.duration)}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SessionGraphCard(session: displaySession),
              const SizedBox(height: 16),
            ],

            // ===== Exercises =====
            /// Execution list for the client’s exercise templates
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Exercises',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (!(isActive == false && displaySession.hrReadings.isNotEmpty))
                  TextButton.icon(
                    onPressed: () async {
                      if (_isEditingExercises) {
                        // Refresh session data when exiting edit mode
                        final latestSession = await widget.viewModel.getLatestSession();
                        if (latestSession != null) {
                          _displaySession = latestSession;
                        }
                        _initializeExerciseState();
                      }
                      setState(() {
                        _isEditingExercises = !_isEditingExercises;
                      });
                    },
                    icon: Icon(_isEditingExercises ? Icons.check : Icons.edit),
                    label: Text(_isEditingExercises ? 'Done' : 'Edit'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            
            if (!_isEditingExercises) ...[
              // Show read-only template cards when session is completed
              if (isActive == false && displaySession.hrReadings.isNotEmpty)
                ..._sessionExercises.map((exercise) {
                  // Check if this exercise was completed (exists in exercisesPerformed)
                  final isCompleted = displaySession.exercisesPerformed.any(
                    (ex) => ex.exerciseId == exercise.exerciseId,
                  );
                  return ExerciseTemplateCard(
                    exercise: exercise,
                    isCompleted: isCompleted,
                  );
                })
              // Show executable cards during active session or before start
              else
                ..._sessionExercises.map((exercise) {
                  return ExecutableExerciseCard(
                    exercise: exercise,
                    isDone: widget.viewModel.isExerciseDone(exercise.exerciseId),
                    stopWatch: _stopWatches[exercise.exerciseId],
                    onDoneChanged: (value) => widget.viewModel.toggleExerciseDone(
                      exercise.exerciseId,
                      value ?? false,
                    ),
                  );
                }),
            ] else
              ExerciseFormWidget(
                viewModel: _exerciseFormViewModel,
                initialExercises: _sessionExercises,
                onCreate: (ex) async {
                  final updatedExercises = List<Exercise>.from(_sessionExercises)..add(ex);
                  await widget.viewModel.updateSessionExercises(updatedExercises);
                  _initializeExerciseState();
                  if (mounted) setState(() {});
                },
                onRemove: (ex) async {
                  final updatedExercises = _sessionExercises
                      .where((e) => e.exerciseId != ex.exerciseId)
                      .toList();
                  await widget.viewModel.updateSessionExercises(updatedExercises);
                  _initializeExerciseState();
                  if (mounted) setState(() {});
                },
              ),
            
            const SizedBox(height: 16),

            // ===== Delete Session Button =====
            /// Available only after a session ends and has recorded data
            if (!isActive && displaySession.hrReadings.isNotEmpty)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
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
                                onPressed: () async {
                                  final updatedClient = await widget.viewModel.deleteLatestSession();
                                  if (!ctx.mounted) return;
                                  Navigator.pop(ctx);
                                  if (!context.mounted) return;
                                  Navigator.pop(context, updatedClient);
                                },
                                child: const Text('Delete', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                      },
                  icon: const Icon(Icons.delete),
                  label: const Text('Delete Session'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
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

String _formatHm(Duration d) {
  final hours = d.inHours;
  final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  return '$hours:$minutes';
}
