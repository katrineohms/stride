// Packages
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

// Files
import '../model/_models.dart';

/// Executable exercise card - with timers and checkboxes
class ExecutableExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final bool isDone;
  final StopWatchTimer? stopWatch;
  final ValueChanged<bool?>? onDoneChanged;
  final HeartRateRecovery? hrrResult;
  final Stream<int>? heartRateStream;
  final VoidCallback? onMeasureHrr;

  const ExecutableExerciseCard({
    super.key,
    required this.exercise,
    this.isDone = false,
    this.stopWatch,
    this.onDoneChanged,
    this.hrrResult,
    this.heartRateStream,
    this.onMeasureHrr,
  });

  @override
  Widget build(BuildContext context) {
    if (exercise is CountableExercise) {
      return _buildCountableCard(context, exercise as CountableExercise);
    } else if (exercise is TimeableExercise) {
      return _buildTimeableCard(context, exercise as TimeableExercise);
    }
    return const SizedBox.shrink();
  }

  Widget _buildCountableCard(BuildContext context, CountableExercise ex) {
    return Card(
      color: Theme.of(context).cardColor,
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Opacity(
              opacity: isDone ? 0.5 : 1.0,
              child: Checkbox(
                value: isDone,
                onChanged: onDoneChanged,
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            Expanded(
              child: Opacity(
                opacity: isDone ? 0.5 : 1.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ex.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                '${ex.sets} sets • ${ex.reps} reps',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (hrrResult != null)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'High: ${hrrResult!.high}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                Text(
                                  'Low: ${hrrResult!.low}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                Text(
                                  'HRR: ${hrrResult!.delta}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Measured: '
                                  '${DateTime.fromMillisecondsSinceEpoch(hrrResult!.timestamp * 1000)}',
                                  style: const TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            _buildHrrButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeableCard(BuildContext context, TimeableExercise ex) {
    return Card(
      color: Theme.of(context).cardColor,
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Opacity(
              opacity: isDone ? 0.5 : 1.0,
              child: Checkbox(
                value: isDone,
                onChanged: onDoneChanged,
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            Expanded(
              child: Opacity(
                opacity: isDone ? 0.5 : 1.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ex.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                '${ex.time} seconds',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (hrrResult != null)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'High: ${hrrResult!.high}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                Text(
                                  'Low: ${hrrResult!.low}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                Text(
                                  'HRR: ${hrrResult!.delta}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (stopWatch != null)
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                if (stopWatch!.isRunning) {
                                  stopWatch!.onStopTimer();
                                } else {
                                  stopWatch!.onStartTimer();
                                }
                              },
                              icon: Icon(
                                stopWatch!.isRunning ? Icons.pause : Icons.play_arrow,
                              ),
                              label: Text(stopWatch!.isRunning ? 'Pause' : 'Start'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => stopWatch!.onResetTimer(),
                              icon: const Icon(Icons.refresh),
                              label: const Text('Reset'),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 8),
                    if (stopWatch != null) ...[
                      StreamBuilder<int>(
                        stream: stopWatch!.rawTime,
                        initialData: stopWatch!.rawTime.value,
                        builder: (context, snapshot) {
                          final value = snapshot.data ?? 0;
                          final displayTime = StopWatchTimer.getDisplayTime(
                            value,
                            hours: false,
                          );
                          // Auto-mark done when timer reaches 0
                          if (value == 0 && !isDone) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              onDoneChanged?.call(true);
                            });
                          }
                          return Center(
                            child: Text(
                              displayTime,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                    ],
                  ],
                ),
              ),
            ),
            _buildHrrButton(context),
          ],
        ),
      ),
    );
  }

  /// Build heart button that changes style after HRR is captured
  Widget _buildHrrButton(BuildContext context) {
    final hasHrr = hrrResult != null;
    final borderRadius = BorderRadius.circular(20);
    
    return Opacity(
      opacity: hasHrr ? 0.5 : 1.0,
      child: Material(
        color: hasHrr
            ? Colors.white
            : Theme.of(context).colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: BorderSide.none,
        ),
        elevation: 1,
        child: InkWell(
          customBorder: RoundedRectangleBorder(
            borderRadius: borderRadius,
          ),
          onTap: onMeasureHrr,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(
              Icons.favorite,
              color: hasHrr
                  ? Theme.of(context).colorScheme.primary
                  : Colors.white,
              size: 16,
            ),
          ),
        ),
      ),
    );
  }
}
