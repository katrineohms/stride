// Packages
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../model/_models.dart';
import '../view_model/movesense_connect_view_model.dart';

// Services
import '../service/movesense_service.dart';

class CreateClientViewModel {
  CreateClientViewModel({MovesenseConnectViewModel? movesense})
      : movesense = movesense ?? MovesenseService().viewModel;

  String name = '';
  int? age;
  String gender = 'Male';
  int active = 0; // 0 = green, 1 = yellow, 2 = red
  String motivation = '';
  final List<Session> scheduledSessions = [];
  final MovesenseConnectViewModel movesense;
  final _uuid = const Uuid();

  // Exercise templates stored on the client
  List<Exercise> exerciseTemplates = [];

  String? validateName() {
    if (name.isEmpty) return 'Enter a name';
    return null;
  }

  String? validateAge() {
    if (age == null || age! <= 0) return 'Enter a valid age';
    return null;
  }

  bool validateAll() {
    return validateName() == null &&
        validateAge() == null;
  }

  Client createClient() {
    if (!validateAll()) {
      throw Exception('Cannot create client: invalid data');
    }

    return Client(
      clientId: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      age: age!,
      gender: gender,
      active: active,
      motivation: motivation,
      exerciseTemplates: exerciseTemplates,
      sessions: List.unmodifiable(scheduledSessions),
    );
  }

  void addScheduledSession(Session session) {
    scheduledSessions.add(session);
  }

  void removeScheduledSession(Session session) {
    scheduledSessions.remove(session);
  }

  Session buildSessionFromPick(DateTime date, TimeOfDay time) {
    final ts = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    ).millisecondsSinceEpoch ~/
        1000;

    return Session(
      sessionId: _uuid.v4(),
      startTime: ts,
      endTime: null,
      hrReadings: const [],
      startLocationCity: null,
      exercisesPerformed: const [],
    );
  }
}
class CreateExerciseViewModel {
  String name = '';
  String description = '';
  int sets = 0;
  int reps = 0;
  int time = 0; // in seconds

  /// true = repetition-based (sets & reps)
  /// false = time-based (time)
  bool isCountable = true;

  // Validation
  String? validateName() {
    if (name.isEmpty) return 'Enter an exercise name';
    return null;
  }

  String? validateSets() {
    if (!isCountable) return null;
    if (sets <= 0) return 'Enter sets';
    return null;
  }

  String? validateReps() {
    if (!isCountable) return null;
    if (reps <= 0) return 'Enter reps';
    return null;
  }

  String? validateTime() {
    if (isCountable) return null;
    if (time <= 0) return 'Enter time in seconds';
    return null;
  }

  bool validateAll() {
    return validateName() == null &&
        validateSets() == null &&
        validateReps() == null &&
        validateTime() == null;
  }

  Exercise createExercise() {
    if (!validateAll()) {
      throw Exception('Cannot create exercise: invalid data');
    }

    final exerciseId = DateTime.now().millisecondsSinceEpoch.toString();

    if (isCountable) {
      return CountableExercise(
        exerciseId: exerciseId,
        name: name,
        description: description,
        sets: sets,
        reps: reps,
      );
    } else {
      return TimeableExercise(
        exerciseId: exerciseId,
        name: name,
        description: description,
        time: time,
      );
    }
  }
}
