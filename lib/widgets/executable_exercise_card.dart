// Packages
import 'package:flutter/material.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

// Files
import '../model/_models.dart';

/// Executable exercise card - with timers, HRR buttons, and checkboxes
class ExecutableExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final bool isDone;
  final StopWatchTimer? stopWatch;
  final ValueChanged<bool?>? onDoneChanged;
  final VoidCallback? onHrrTap;
  final HeartRateRecovery? hrr;

  const ExecutableExerciseCard({
    super.key,
    required this.exercise,
    this.isDone = false,
    this.stopWatch,
    this.onDoneChanged,
    this.onHrrTap,
    this.hrr,
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
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
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
            const SizedBox(height: 4),
            Text('${ex.sets} sets × ${ex.reps} reps'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: isDone,
                      onChanged: onDoneChanged,
                    ),
                    const Text('Done'),
                  ],
                ),
                if (hrr != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('High: ${hrr!.high}', style: const TextStyle(fontSize: 12)),
                      Text('Low: ${hrr!.low}', style: const TextStyle(fontSize: 12)),
                      Text('HRR: ${hrr!.delta}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  )
                else
                  ElevatedButton.icon(
                    onPressed: onHrrTap,
                    icon: const Icon(Icons.favorite, size: 16),
                    label: const Text('HRR'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeableCard(BuildContext context, TimeableExercise ex) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
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
            const SizedBox(height: 4),
            Text('${ex.time} seconds'),
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
              SizedBox(
                width: double.infinity,
                child: hrr != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('High: ${hrr!.high} bpm', style: const TextStyle(fontSize: 12)),
                          Text('Low: ${hrr!.low} bpm', style: const TextStyle(fontSize: 12)),
                          Text('HRR: ${hrr!.delta} bpm', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      )
                    : ElevatedButton.icon(
                        onPressed: onHrrTap,
                        icon: const Icon(Icons.favorite, size: 16),
                        label: const Text('Measure HRR'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
