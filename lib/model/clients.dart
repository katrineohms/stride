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

class HeartRateRecovery {
  final int high;
  final int low;

  const HeartRateRecovery({required this.high, required this.low});

  int get delta => high - low;
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

class Appointment {
  final int timestamp; // Unix timestamp (seconds since epoch)
  final String? notes; // optional notes

  Appointment({
    required this.timestamp,
    this.notes,
  });

  DateTime get dateTime => DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
}
class Client {
  final String clientId;
  final String name;
  final int age;
  final String gender;
  final int active;
  final List<Appointment> appointments;
  final String motivation;
  final List<Exercise> exercises;
  final Map<String, HeartRateRecovery> hrrResults;

  Client({
    required this.clientId,
    required this.name,
    required this.age,
    required this.gender,
    required this.active,
    List<Appointment>? appointments,
    required this.motivation,
    List<Exercise>? exercises,
    Map<String, HeartRateRecovery>? hrrResults,
  })  : appointments = List.unmodifiable(appointments ?? []),
      exercises = List.unmodifiable(exercises ?? []),
      hrrResults = Map.unmodifiable(hrrResults ?? {});

  Client copyWith({
    String? clientId,
    String? name,
    int? age,
    String? gender,
    int? active,
    List<Appointment>? appointments,
    String? motivation,
    List<Exercise>? exercises,
    Map<String, HeartRateRecovery>? hrrResults,
  }) {
    return Client(
      clientId: clientId ?? this.clientId,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      active: active ?? this.active,
      appointments: appointments ?? this.appointments,
      motivation: motivation ?? this.motivation,
      exercises: exercises ?? this.exercises,
      hrrResults: hrrResults ?? this.hrrResults,
    );
  }
}
