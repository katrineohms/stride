class Exercise {
  final String exerciseId;
  final String name;
  final String description;
  final bool isCompleted;

  Exercise({
    required this.exerciseId,
    required this.name,
    required this.description,
    this.isCompleted = false,
  });

  Exercise copyWith({bool? isCompleted}) {
    return Exercise(
      exerciseId: exerciseId,
      name: name,
      description: description,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
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
  final Appointment appointment; // the appointment this session fulfills
  final int startTime; // Unix timestamp in seconds (when session actually started)
  final int? endTime; // null if session is active
  final List<HrReading> hrReadings;
  final String? startLocationCity; // city name from reverse geocoding
  final List<Exercise> exercises; // exercises performed in this session
  final Map<String, HeartRateRecovery> hrrResults; // HRR results for exercises in this session

  const Session({
    required this.sessionId,
    required this.appointment,
    required this.startTime,
    this.endTime,
    required this.hrReadings,
    this.startLocationCity,
    List<Exercise>? exercises,
    Map<String, HeartRateRecovery>? hrrResults,
  })  : exercises = exercises ?? const [],
        hrrResults = hrrResults ?? const {};

  bool get isActive => endTime == null;
  
  Duration get duration => Duration(
    seconds: (endTime ?? (DateTime.now().millisecondsSinceEpoch ~/ 1000)) - startTime,
  );

  Session copyWith({
    String? sessionId,
    Appointment? appointment,
    int? startTime,
    int? endTime,
    List<HrReading>? hrReadings,
    String? startLocationCity,
    List<Exercise>? exercises,
    Map<String, HeartRateRecovery>? hrrResults,
  }) {
    return Session(
      sessionId: sessionId ?? this.sessionId,
      appointment: appointment ?? this.appointment,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      hrReadings: hrReadings ?? this.hrReadings,
      startLocationCity: startLocationCity ?? this.startLocationCity,
      exercises: exercises ?? this.exercises,
      hrrResults: hrrResults ?? this.hrrResults,
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
    super.isCompleted,
  });

  @override
  CountableExercise copyWith({bool? isCompleted}) {
    return CountableExercise(
      exerciseId: exerciseId,
      name: name,
      description: description,
      reps: reps,
      sets: sets,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class TimeableExercise extends Exercise {
  final int time; // duration in minutes

  TimeableExercise({
    required super.exerciseId,
    required super.name,
    required super.description,
    required this.time,
    super.isCompleted,
  });

  @override
  TimeableExercise copyWith({bool? isCompleted}) {
    return TimeableExercise(
      exerciseId: exerciseId,
      name: name,
      description: description,
      time: time,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class Appointment {
  final int timestamp; // Unix timestamp (seconds since epoch)
  final String? notes; // optional notes
  final bool isCompleted; // whether the session for this appointment happened

  Appointment({
    required this.timestamp,
    this.notes,
    this.isCompleted = false,
  });

  DateTime get dateTime => DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);

  Appointment copyWith({
    int? timestamp,
    String? notes,
    bool? isCompleted,
  }) {
    return Appointment(
      timestamp: timestamp ?? this.timestamp,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
class Client {
  final String clientId;
  final String name;
  final int age;
  final String gender;
  final int active;
  final String motivation;
  final List<Exercise> exerciseTemplates; // template exercises that can be copied to sessions
  final List<Session> sessions; // all sessions (appointments + completion data)

  Client({
    required this.clientId,
    required this.name,
    required this.age,
    required this.gender,
    required this.active,
    required this.motivation,
    List<Exercise>? exerciseTemplates,
    List<Session>? sessions,
  })  : exerciseTemplates = List.unmodifiable(exerciseTemplates ?? []),
        sessions = List.unmodifiable(sessions ?? []);

  /// Get upcoming appointments (sessions with appointment timestamp >= now and not completed)
  List<Session> get upcomingAppointments {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return sessions
        .where((s) => !s.appointment.isCompleted && s.appointment.timestamp >= now)
        .toList()
      ..sort((a, b) => a.appointment.timestamp.compareTo(b.appointment.timestamp));
  }

  /// Get past/completed sessions
  List<Session> get completedSessions {
    return sessions
        .where((s) => s.appointment.isCompleted)
        .toList()
      ..sort((a, b) => b.appointment.timestamp.compareTo(a.appointment.timestamp));
  }

  Client copyWith({
    String? clientId,
    String? name,
    int? age,
    String? gender,
    int? active,
    String? motivation,
    List<Exercise>? exerciseTemplates,
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
      sessions: sessions ?? this.sessions,
    );
  }
}
