// Plugins
import 'dart:async';
import 'dart:math';

// Packages
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

// Files
import '../model/clients.dart';
import '../view_model/client_card_view_model.dart';
import '../view_model/widgets_view_model/ui_event.dart';
import '../view/edit_client_view.dart';
import '../widgets/movesense_status_widget.dart';
import '../widgets/stop_watch_timer_widget.dart';

/// ===== Helper =====
Color getStatusColor(int active) {
  switch (active) {
    case 0:
      return Colors.green;
    case 1:
      return Colors.yellow;
    case 2:
      return Colors.red;
    default:
      return Colors.grey;
  }
}

/// ===== Helper to get next upcoming session time =====
DateTime? getNextSessionTime(Client client) {
  final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  final futureSessions = client.sessions
      .where((s) => s.startTime >= now && s.endTime == null)
      .toList();

  if (futureSessions.isEmpty) return null;

  futureSessions.sort((a, b) => a.startTime.compareTo(b.startTime));
  return DateTime.fromMillisecondsSinceEpoch(
    futureSessions.first.startTime * 1000,
  );
}

/// ===== Client Card =====
class ClientCard extends StatelessWidget {
  final Client client;
  final VoidCallback? onTap;

  const ClientCard({super.key, required this.client, this.onTap});

  @override
  Widget build(BuildContext context) {
      final nextSession = getNextSessionTime(client);

      final timeStr = nextSession != null
      ? '${nextSession.hour.toString().padLeft(2, '0')}:'
        '${nextSession.minute.toString().padLeft(2, '0')}'
      : 'No upcoming';

    return Card(
      color: Theme.of(context).cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Text(
            client.name[0],
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(client.name)),
            Text(
              timeStr,
              style: const TextStyle(color: Color.fromARGB(255, 80, 80, 80)),
            ),
          ],
        ),
        subtitle: Text('${client.age} years old, ${client.gender}'),
        trailing: Icon(Icons.circle, color: getStatusColor(client.active)),
        onTap: onTap,
      ),
    );
  }
}

/// ===== Client Detail View =====
class ClientDetailViewWidget extends StatefulWidget {
  final ClientDetailViewModel viewModel;
  final Map<String, bool> exerciseDone;
  final Map<String, StopWatchTimer> stopWatches;
  final void Function(String, bool?) onToggleDone;
  final ValueChanged<Client>? onClientUpdated;
  final VoidCallback? onMovesenseTap;

  const ClientDetailViewWidget({
    super.key,
    required this.viewModel,
    required this.exerciseDone,
    required this.stopWatches,
    required this.onToggleDone,
    this.onClientUpdated,
    this.onMovesenseTap,
  });

  @override
  State<ClientDetailViewWidget> createState() => _ClientDetailViewWidgetState();
}

class _ClientDetailViewWidgetState extends State<ClientDetailViewWidget> {
  late Client _client;
  late Map<String, HeartRateRecovery> _hrrResults;
  late final StreamSubscription<UiEvent> _eventSub;

  @override
  void initState() {
    super.initState();
    _client = widget.viewModel.client;
    _hrrResults = Map<String, HeartRateRecovery>.from(_client.hrrResults);
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
      } else if (event is NavigationEvent) {
        Navigator.of(context).pushNamed(
          event.route,
          arguments: event.arguments,
        );
      }
    });
  }

  @override
  void dispose() {
    _eventSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final client = _client;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 56),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== Header: Avatar + Name + Status =====
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(
                  client.name[0],
                  style: const TextStyle(color: Colors.white, fontSize: 30),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // ===== Client Name =====
                        Expanded(
                          child: Text(
                            client.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        // ===== Trailing Buttons =====
                        Row(
                          mainAxisSize: MainAxisSize
                              .min, // makes the inner row wrap its children
                          children: [
                            IconButton(
                              icon: const Icon(Icons.add, size: 24),
                              onPressed: () {
                                // TODO: Add new session scheduling flow
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, size: 24),
                              onPressed: () async {
                                final updatedClient =
                                    await Navigator.push<Client>(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            EditClientPage(client: client),
                                      ),
                                    );

                                if (!mounted) return;

                                if (updatedClient != null) {
                                  // Persist and refresh via view model
                                  widget.viewModel.updateClient(updatedClient);
                                  widget.onClientUpdated
                                      ?.call(updatedClient);
                                  if (mounted) {
                                    setState(() {
                                      _client = updatedClient;
                                      _hrrResults = Map<String,
                                              HeartRateRecovery>.from(
                                          updatedClient.hrrResults);
                                    });
                                  }
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Client updated'),
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Text('Status: '),
                        Icon(
                          Icons.circle,
                          color: getStatusColor(client.active),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ===== Movesense Status =====
          ListenableBuilder(
            listenable: widget.viewModel.movesense,
            builder: (context, _) {
              final movesense = widget.viewModel.movesense;
              return MoveSenseStatusCard(
                connected: movesense.isConnected,
                heartRate: 0,
                heartRateStream: movesense.heartRateStream,
                batteryOk: true,
                batteryStream: movesense.batteryStream,
                onTap: widget.onMovesenseTap,
              );
            },
          ),
          const SizedBox(height: 16),

          // ===== Session Control =====
          _buildSessionControl(context),
          const SizedBox(height: 16),

          // ===== Personal Info Card =====
          SizedBox(
            width: double.infinity,
            child: Card(
              color: Theme.of(context).cardColor,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Personal Info',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Age: ${client.age}'),
                    Text('Gender: ${client.gender}'),
                    const SizedBox(height: 8),
                    const Text(
                      'Motivation:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      client.motivation.isNotEmpty
                          ? client.motivation
                          : 'No motivation notes added.',
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ===== Sessions Card (scheduled) =====
          SizedBox(
            width: double.infinity,
            child: Card(
              color: Theme.of(context).cardColor,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Upcoming Sessions',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._buildUpcomingSessions(client),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ===== Exercises =====
          const Text(
            'Exercises',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Column(
            children: client.exerciseTemplates.map((exercise) {
              final done = widget.exerciseDone[exercise.exerciseId] ?? false;
              final stopWatch = widget.stopWatches[exercise.exerciseId];
              final hrr = _hrrResults[exercise.exerciseId];

              return SizedBox(
                width: double.infinity,
                child: Card(
                  color: Theme.of(context).cardColor,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top row: name + sets/reps or time
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                exercise.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  decoration: done
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: done ? Colors.grey : null,
                                ),
                              ),
                            ),
                            if (exercise is CountableExercise)
                              Text(
                                '${exercise.sets} sets • ${exercise.reps} reps',
                              )
                            else if (exercise is TimeableExercise)
                              Text('Time: ${exercise.time}s'),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Row: checkbox / stopwatch + heart button
                        Row(
                          children: [
                            if (exercise is CountableExercise)
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Checkbox(
                                    value: done,
                                    onChanged: (val) => widget.onToggleDone(
                                      exercise.exerciseId,
                                      val,
                                    ),
                                  ),
                                ),
                              ),
                            if (exercise is TimeableExercise &&
                                stopWatch != null)
                              Expanded(
                                child: StopwatchWidget(
                                  stopWatchTimer: stopWatch,
                                ),
                              ),

                            if (hrr != null)
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'High: ${hrr.high}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    Text(
                                      'Low: ${hrr.low}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    Text(
                                      'HRR: ${hrr.delta}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // Heart button (changes style after HRR captured)
                            Builder(
                              builder: (context) {
                                final hasHrr = hrr != null;
                                final borderRadius = BorderRadius.circular(20);
                                final borderColor =
                                    Theme.of(context).colorScheme.primary;
                                return Material(
                                  color: hasHrr
                                      ? Colors.white
                                      : Theme.of(context)
                                          .colorScheme
                                          .primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: borderRadius,
                                    side: hasHrr
                                        ? BorderSide(color: borderColor)
                                        : BorderSide.none,
                                  ),
                                  elevation: 1,
                                  child: InkWell(
                                    customBorder: RoundedRectangleBorder(
                                      borderRadius: borderRadius,
                                    ),
                                    onTap: () => _startHeartRateRecovery(
                                      context,
                                      exercise.exerciseId,
                                      exercise.name,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Icon(
                                        Icons.favorite,
                                        color: hasHrr
                                            ? const Color.fromARGB(
                                                255,
                                                210,
                                                57,
                                                62,
                                              )
                                            : Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
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

    const measurementDuration = Duration(seconds: 60); // standard HRR window
    final readings = <int>[];
    final timeLeft = ValueNotifier<int>(measurementDuration.inSeconds);
    final lastHr = ValueNotifier<int?>(null);

    StreamSubscription<int>? sub;
    Timer? countdown;

    // Show a blocking dialog while measuring.
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
      if (hr <= 0) return; // ignore invalid readings
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

    if (mounted) {
      setState(() {
        final updated = _client.copyWith(
          hrrResults: Map<String, HeartRateRecovery>.from(_hrrResults)
            ..[exerciseId] = HeartRateRecovery(high: maxHr, low: minHr),
        );
        widget.viewModel.setHeartRateRecovery(
          exerciseId,
          HeartRateRecovery(high: maxHr, low: minHr),
        );
        _hrrResults = Map<String, HeartRateRecovery>.from(updated.hrrResults);
        _client = updated;
      });
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

  /// Build session control card
  Widget _buildSessionControl(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final isActive = widget.viewModel.isSessionActiveForClient;

        // Show graph if there's a completed session
        final latestSession = _client.sessions.isNotEmpty
            ? _client.sessions.last
            : null;
        
        if (!isActive && latestSession != null && !latestSession.isActive) {
          return _buildSessionGraph(latestSession);
        }

        return Card(
          color: Theme.of(context).cardColor,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'HR Session',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (isActive) ...[
                      StreamBuilder<void>(
                        stream: Stream.periodic(const Duration(seconds: 1)),
                        builder: (context, _) {
                          final duration = widget.viewModel.sessionDuration;
                          final hours = duration?.inHours ?? 0;
                          final minutes = (duration?.inMinutes ?? 0) % 60;
                          final seconds = (duration?.inSeconds ?? 0) % 60;
                          return Text(
                            '${hours.toString().padLeft(2, '0')}:'
                            '${minutes.toString().padLeft(2, '0')}:'
                            '${seconds.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                if (isActive) ...[
                  StreamBuilder<void>(
                    stream: Stream.periodic(const Duration(seconds: 1)),
                    builder: (context, _) {
                      final hr = widget.viewModel.currentSessionHeartRate;
                      return Row(
                        children: [
                          const Icon(Icons.favorite,
                              color: Color.fromARGB(255, 210, 57, 62)),
                          const SizedBox(width: 8),
                          Text(
                            hr != null ? '$hr bpm' : 'Waiting for HR...',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                ],
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _toggleSession(context),
                    icon: Icon(isActive ? Icons.stop : Icons.play_arrow),
                    label: Text(isActive ? 'Stop Session' : 'Start Session'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isActive ? Colors.red : Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Toggle session start/stop
  Future<void> _toggleSession(BuildContext context) async {
    final isActive = widget.viewModel.isSessionActiveForClient;

    if (isActive) {
      // Confirm stop
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Stop Session?'),
          content: const Text(
            'Are you sure you want to stop the current session? '
            'All collected HR data will be saved.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Stop'),
            ),
          ],
        ),
      );

      if (confirm == true) {
        await widget.viewModel.stopSessionAndRefresh();

        if (!context.mounted) return;
        if (mounted) {
          setState(() {
            _client = widget.viewModel.client;
          });
        }
      }
    } else {
      try {
        await widget.viewModel.startSession();
      } catch (e) {
        widget.viewModel.events.emit(
          SnackBarEvent('Error starting session: $e', isError: true),
        );
      }
    }
  }

  /// Build list of upcoming sessions for the client.
  List<Widget> _buildUpcomingSessions(Client client) {
    final nowSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final upcoming = client.sessions
        .where((s) => s.startTime >= nowSeconds)
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    if (upcoming.isEmpty) {
      return const [
        Text('No upcoming sessions scheduled.'),
      ];
    }

    return upcoming.map((session) {
      final start =
          DateTime.fromMillisecondsSinceEpoch(session.startTime * 1000);
      final dateStr =
          '${start.year}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}';
      final timeStr =
          '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text('$dateStr at $timeStr')),
          ],
        ),
      );
    }).toList();
  }

  /// Build session graph card
  Widget _buildSessionGraph(Session session) {
    final startTime = DateTime.fromMillisecondsSinceEpoch(session.startTime * 1000);
    final endTime = session.endTime != null
        ? DateTime.fromMillisecondsSinceEpoch(session.endTime! * 1000)
        : DateTime.now();
    final duration = session.duration;
    final startCity = session.startLocationCity;

    // Calculate stats
    final hrValues = session.hrReadings.map((r) => r.heartRate).toList();
    final avgHr = hrValues.isEmpty
        ? 0
        : hrValues.reduce((a, b) => a + b) ~/ hrValues.length;
    final maxHr = hrValues.isEmpty ? 0 : hrValues.reduce(max);
    final minHr = hrValues.isEmpty ? 0 : hrValues.reduce(min);

    // Prepare chart data
    final spots = <FlSpot>[];
    if (session.hrReadings.isNotEmpty) {
      final baseTime = session.startTime;
      for (final reading in session.hrReadings) {
        final minutesElapsed = (reading.timestamp - baseTime) / 60.0;
        spots.add(FlSpot(minutesElapsed, reading.heartRate.toDouble()));
      }
    }

    return Card(
      color: Theme.of(context).cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Latest Session',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                    onPressed: () {
                      setState(() {
                        widget.viewModel.deleteLatestSession();
                        _client = widget.viewModel.client;
                      });
                    },
                  tooltip: 'Delete session',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${startTime.hour.toString().padLeft(2, '0')}:'
              '${startTime.minute.toString().padLeft(2, '0')} - '
              '${endTime.hour.toString().padLeft(2, '0')}:'
              '${endTime.minute.toString().padLeft(2, '0')} '
              '(${duration.inMinutes} min)',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            if (startCity != null) ...[
              const SizedBox(height: 6),
              Text(
                'Location: $startCity',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
            const SizedBox(height: 12),
            // Stats row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Avg', '$avgHr', 'bpm'),
                _buildStatItem('Max', '$maxHr', 'bpm'),
                _buildStatItem('Min', '$minHr', 'bpm'),
              ],
            ),
            const SizedBox(height: 16),
            // Chart
            if (spots.isNotEmpty)
              SizedBox(
                height: 180,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      horizontalInterval: 20,
                      verticalInterval: 5,
                    ),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          interval: 5,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              '${value.toInt()}m',
                              style: const TextStyle(fontSize: 10),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          interval: 20,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: const TextStyle(fontSize: 10),
                            );
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    minX: 0,
                    maxX: (duration.inMinutes > 0 
                        ? duration.inMinutes.toDouble() * 1.1 // Add 10% padding
                        : 5),
                    minY: max(minHr - 10, 40).toDouble(),
                    maxY: (maxHr + 10).toDouble(),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: const Color.fromARGB(255, 210, 57, 62),
                        barWidth: 2,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: const Color.fromARGB(255, 210, 57, 62)
                              .withValues(alpha: 0.1),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              const Center(
                child: Text('No heart rate data recorded'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, String unit) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (unit.isNotEmpty) ...[
              const SizedBox(width: 2),
              Text(
                unit,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

}

