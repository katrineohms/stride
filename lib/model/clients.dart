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

class HrReading {
  final int timestamp; // Unix timestamp in seconds
  final int heartRate;

  const HrReading({required this.timestamp, required this.heartRate});
}

class Appointment {
  final int timestamp; // Unix timestamp in seconds
  final String notes;

  const Appointment({required this.timestamp, this.notes = ''});
}

class Session {
  final String sessionId;
  final int startTime; // scheduled or actual start, Unix seconds
  final int? endTime; // null if session is active
  final List<HrReading> hrReadings;
  final String? startLocationCity; // city name from reverse geocoding
  final List<Exercise> exercisesPerformed;
  final Map<String, HeartRateRecovery> hrrResults;
  final String? notes;

  Session({
    required this.sessionId,
    required this.startTime,
    this.endTime,
    required List<HrReading> hrReadings,
    this.startLocationCity,
    List<Exercise>? exercisesPerformed,
    Map<String, HeartRateRecovery>? hrrResults,
    this.notes,
  })  : hrReadings = List.unmodifiable(hrReadings),
        exercisesPerformed = List.unmodifiable(exercisesPerformed ?? []),
        hrrResults = Map.unmodifiable(hrrResults ?? {});

  bool get isActive => endTime == null;

  Duration get duration => Duration(
        seconds:
            (endTime ?? (DateTime.now().millisecondsSinceEpoch ~/ 1000)) -
                startTime,
      );

  Session copyWith({
    String? sessionId,
    int? startTime,
    int? endTime,
    List<HrReading>? hrReadings,
    String? startLocationCity,
    List<Exercise>? exercisesPerformed,
    Map<String, HeartRateRecovery>? hrrResults,
    String? notes,
  }) {
    return Session(
      sessionId: sessionId ?? this.sessionId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      hrReadings: hrReadings ?? this.hrReadings,
      startLocationCity: startLocationCity ?? this.startLocationCity,
      exercisesPerformed: exercisesPerformed ?? this.exercisesPerformed,
      hrrResults: hrrResults ?? this.hrrResults,
      notes: notes ?? this.notes,
    );
  }
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
  final String motivation;
  /// Exercise templates owned by the client (copied into sessions when used)
  final List<Exercise> exerciseTemplates;
  final Map<String, HeartRateRecovery> hrrResults;
  final List<Session> sessions;

  Client({
    required this.clientId,
    required this.name,
    required this.age,
    required this.gender,
    required this.active,
    required this.motivation,
    List<Exercise>? exerciseTemplates,
    Map<String, HeartRateRecovery>? hrrResults,
    List<Session>? sessions,
  })  : exerciseTemplates = List.unmodifiable(exerciseTemplates ?? []),
        hrrResults = Map.unmodifiable(hrrResults ?? {}),
        sessions = List.unmodifiable(sessions ?? []);

  Client copyWith({
    String? clientId,
    String? name,
    int? age,
    String? gender,
    int? active,
    String? motivation,
    List<Exercise>? exerciseTemplates,
    Map<String, HeartRateRecovery>? hrrResults,
    List<Session>? sessions,
  }) {
    return Client(
      clientId: clientId ?? this.clientId,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      active: active ?? this.active,
      motivation: motivation ?? this.motivation,
      exerciseTemplates: exerciseTemplates ?? this.exerciseTemplates,
      hrrResults: hrrResults ?? this.hrrResults,
      sessions: sessions ?? this.sessions,
    );
  }
}
