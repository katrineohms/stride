// Packages
import 'package:flutter/material.dart';

// Files
import '../model/_models.dart';

/// Exercise template card - read-only display for client overview
class ExerciseTemplateCard extends StatelessWidget {
  final Exercise exercise;
  final bool isCompleted;

  const ExerciseTemplateCard({
    super.key,
    required this.exercise,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    String subtitle = '';
    if (exercise is CountableExercise) {
      final ex = exercise as CountableExercise;
      subtitle = '${ex.sets} sets × ${ex.reps} reps';
    } else if (exercise is TimeableExercise) {
      final ex = exercise as TimeableExercise;
      subtitle = '${ex.time} seconds';
    }

    return Card(
      color: Theme.of(context).cardColor,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          isCompleted ? Icons.check_circle : Icons.fitness_center,
          color: isCompleted ? Colors.green : null,
        ),
        title: Text(
          exercise.name,
          style: isCompleted
              ? const TextStyle(decoration: TextDecoration.lineThrough)
              : null,
        ),
        subtitle: Text(subtitle),
      ),
    );
  }
}
