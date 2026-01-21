import 'exercise.dart';
import 'heart_rate.dart';

class Session {
  final String sessionId;
  final int startTime; // scheduled or actual start, Unix seconds
  final int? endTime; // null if session is active
  final List<HrReading> hrReadings;
  final String? startLocationCity; // city name from reverse geocoding
  final List<Exercise> exercisesPerformed;

  Session({
    required this.sessionId,
    required this.startTime,
    this.endTime,
    required List<HrReading> hrReadings,
    this.startLocationCity,
    List<Exercise>? exercisesPerformed,
  })  : hrReadings = List.unmodifiable(hrReadings),
        exercisesPerformed = List.unmodifiable(exercisesPerformed ?? []);

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
  }) {
    return Session(
      sessionId: sessionId ?? this.sessionId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      hrReadings: hrReadings ?? this.hrReadings,
      startLocationCity: startLocationCity ?? this.startLocationCity,
      exercisesPerformed: exercisesPerformed ?? this.exercisesPerformed,
    );
  }
}
