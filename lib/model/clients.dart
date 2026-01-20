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

class Session {
  final String sessionId;
  final int startTime; // Unix timestamp in seconds
  final int? endTime; // null if session is active
  final List<HrReading> hrReadings;
  final double? startLatitude;
  final double? startLongitude;
  final double? endLatitude;
  final double? endLongitude;

  const Session({
    required this.sessionId,
    required this.startTime,
    this.endTime,
    required this.hrReadings,
    this.startLatitude,
    this.startLongitude,
    this.endLatitude,
    this.endLongitude,
  });

  bool get isActive => endTime == null;
  
  Duration get duration => Duration(
    seconds: (endTime ?? (DateTime.now().millisecondsSinceEpoch ~/ 1000)) - startTime,
  );

  Session copyWith({
    String? sessionId,
    int? startTime,
    int? endTime,
    List<HrReading>? hrReadings,
    double? startLatitude,
    double? startLongitude,
    double? endLatitude,
    double? endLongitude,
  }) {
    return Session(
      sessionId: sessionId ?? this.sessionId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      hrReadings: hrReadings ?? this.hrReadings,
      startLatitude: startLatitude ?? this.startLatitude,
      startLongitude: startLongitude ?? this.startLongitude,
      endLatitude: endLatitude ?? this.endLatitude,
      endLongitude: endLongitude ?? this.endLongitude,
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
  final List<Session> sessions;

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
    List<Session>? sessions,
  })  : appointments = List.unmodifiable(appointments ?? []),
      exercises = List.unmodifiable(exercises ?? []),
      hrrResults = Map.unmodifiable(hrrResults ?? {}),
      sessions = List.unmodifiable(sessions ?? []);

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
    List<Session>? sessions,
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
      sessions: sessions ?? this.sessions,
    );
  }
}
