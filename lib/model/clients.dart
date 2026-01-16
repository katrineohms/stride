class Exercise {
  final String exerciseId;
  final String name;
  final String description;

  Exercise({
    required this.exerciseId,
    required this.name,
    required this.description,
  });
}

class CountableExercise extends Exercise {
  final int reps;
  final int sets;

  CountableExercise({
    required super.exerciseId,
    required super.name,
    required super.description,
    required this.reps,
    required this.sets,
  });
}

class TimeableExercise extends Exercise {
  final int time; // e.g. reps, steps, etc.

  TimeableExercise({
    required super.exerciseId,
    required super.name,
    required super.description,
    required this.time,
  });

}



class Client {
  final String clientId;
  final String name;
  final int age;
  final String gender;
  final int active;
  final int nextAppointment; // Unix timestamp
  final String motivation;
  final List<Exercise> exercises;

  Client({
    required this.clientId,
    required this.name,
    required this.age,
    required this.gender,
    required this.active,
    required this.nextAppointment,
    required this.motivation,
     List<Exercise>? exercises,
  }) : exercises = exercises ?? [];
}
