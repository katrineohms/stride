// Packages
import 'package:flutter/material.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

/// StopwatchWidget displays a stopwatch timer with start, pause, and reset controls.
class StopwatchWidget extends StatelessWidget {
  // The StopWatchTimer instance to control the timer
  final StopWatchTimer stopWatchTimer;
  const StopwatchWidget({super.key, required this.stopWatchTimer});

  @override
  Widget build(BuildContext context) {
    final stopWatch = stopWatchTimer;

    return Row(
      children: [
        // Display the current stopwatch time
        StreamBuilder<int>(
          stream: stopWatch.rawTime,
          initialData: 0,
          builder: (context, snapshot) {
            final displayTime = StopWatchTimer.getDisplayTime(
              snapshot.data!,
              milliSecond: true,
              hours: false,
            );
            return Text(displayTime, style: const TextStyle(fontSize: 16));
          },
        ),
        // Start button
        IconButton(
          icon: const Icon(Icons.play_arrow),
          onPressed: () => stopWatch.onStartTimer(),
        ),
        // Pause button
        IconButton(
          icon: const Icon(Icons.pause),
          onPressed: () => stopWatch.onStopTimer(),
        ),
        // Reset button
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => stopWatch.onResetTimer(),
        ),
      ],
    );
  }
}
