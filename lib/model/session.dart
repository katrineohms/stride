import 'exercise.dart';
import 'heart_rate.dart';

class Session {
  final String sessionId;
  final int startTime; // scheduled start time (unix seconds)
  final int? actualStartTime; // actual start (unix seconds), null if not started
  final int? endTime; // null if session is active
  final List<HrReading> hrReadings;
  final String? startLocationCity; // city name from reverse geocoding
  final List<Exercise> exercisesPerformed;

  Session({
    required this.sessionId,
    required this.startTime,
    this.actualStartTime,
    this.endTime,
    required List<HrReading> hrReadings,
    this.startLocationCity,
    List<Exercise>? exercisesPerformed,
  })  : hrReadings = List.unmodifiable(hrReadings),
        exercisesPerformed = List.unmodifiable(exercisesPerformed ?? []);

  bool get isActive => endTime == null;

  int get effectiveStartTime => actualStartTime ?? startTime;

  Duration get duration => Duration(
        seconds: (endTime ?? (DateTime.now().millisecondsSinceEpoch ~/ 1000)) -
            effectiveStartTime,
      );

  Session copyWith({
    String? sessionId,
    int? startTime,
    int? actualStartTime,
    int? endTime,
    List<HrReading>? hrReadings,
    String? startLocationCity,
    List<Exercise>? exercisesPerformed,
  }) {
    return Session(
      sessionId: sessionId ?? this.sessionId,
      startTime: startTime ?? this.startTime,
      actualStartTime: actualStartTime ?? this.actualStartTime,
      endTime: endTime ?? this.endTime,
      hrReadings: hrReadings ?? this.hrReadings,
      startLocationCity: startLocationCity ?? this.startLocationCity,
      exercisesPerformed: exercisesPerformed ?? this.exercisesPerformed,
    );
  }
}
