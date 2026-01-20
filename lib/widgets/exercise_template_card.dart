// Packages
import 'package:flutter/material.dart';

// Files
import '../model/_models.dart';

/// Exercise template card - read-only display for client overview
class ExerciseTemplateCard extends StatelessWidget {
  final Exercise exercise;

  const ExerciseTemplateCard({
    super.key,
    required this.exercise,
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
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.fitness_center),
        title: Text(exercise.name),
        subtitle: Text(subtitle),
      ),
    );
  }
}
