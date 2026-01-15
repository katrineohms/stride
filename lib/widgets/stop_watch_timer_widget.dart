import 'package:flutter/material.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class StopwatchWidget extends StatelessWidget {
  final StopWatchTimer stopWatchTimer;
  const StopwatchWidget({super.key, required this.stopWatchTimer});

  @override
  Widget build(BuildContext context) {
    final stopWatch = stopWatchTimer;

    return Row(
      children: [
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
        IconButton(
          icon: const Icon(Icons.play_arrow),
          onPressed: () => stopWatch.onStartTimer(),
        ),
        IconButton(
          icon: const Icon(Icons.pause),
          onPressed: () => stopWatch.onStopTimer(),
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => stopWatch.onResetTimer(),
        ),
      ],
    );
  }
}
