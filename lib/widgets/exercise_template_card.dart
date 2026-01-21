// Packages
import 'package:flutter/material.dart';

// Files
import '../model/_models.dart';
import '../model/heart_rate.dart';

/// Exercise template card - read-only display for client overview
class ExerciseTemplateCard extends StatelessWidget {
  final Exercise exercise;
  final bool isCompleted;
  final HeartRateRecovery? hrrResult;

  const ExerciseTemplateCard({
    super.key,
    required this.exercise,
    this.isCompleted = false,
    this.hrrResult,
  });

  @override
  Widget build(BuildContext context) {
    String subtitle = '';
    if (exercise is CountableExercise) {
      final ex = exercise as CountableExercise;
      subtitle = '${ex.sets} sets • ${ex.reps} reps';
    } else if (exercise is TimeableExercise) {
      final ex = exercise as TimeableExercise;
      subtitle = '${ex.time} seconds';
    }

    return Card(
      color: Theme.of(context).cardColor,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: isCompleted
            ? CircleAvatar(
                radius: 14,
                backgroundColor: Colors.green,
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                ),
              )
            : const Icon(Icons.fitness_center),
        title: Text(
          exercise.name,
          // Keep text styling consistent; no strikethrough on completion
          style: null,
        ),
        subtitle: Text(subtitle),
        trailing: hrrResult == null
            ? null
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('High: ${hrrResult!.high}', style: const TextStyle(fontSize: 12)),
                  Text('Low: ${hrrResult!.low}', style: const TextStyle(fontSize: 12)),
                  Text(
                    'HRR: ${hrrResult!.delta}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
      ),
    );
  }
}
