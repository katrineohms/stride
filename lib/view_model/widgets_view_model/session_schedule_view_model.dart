// Packages
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

// Files
import '../../model/_models.dart';

/// ===============================
/// SessionScheduleViewModel
/// ===============================
/// ViewModel for managing session scheduling state and logic.
class SessionScheduleViewModel {
  // ====== Private Fields ======
  final List<Session> _sessions = [];
  final _uuid = const Uuid();

  // ====== Public Getters ======
  List<Session> get sessions => List.unmodifiable(_sessions);

  // ====== Initialization ======
  void initialize(List<Session> initialSessions) {
    _sessions
      ..clear()
      ..addAll(initialSessions);
  }

  // ====== Session Creation ======
  Session createScheduledSession(
    DateTime pickedDate,
    TimeOfDay pickedTime, {
    String? notes,
  }) {
    final timestamp = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    ).millisecondsSinceEpoch ~/
        1000;

    return Session(
      sessionId: _uuid.v4(),
      startTime: timestamp,
      endTime: null,
      hrReadings: const [],
      startLocationCity: null,
      exercisesPerformed: const [],
    );
  }

  // ====== Session Management ======
  void addSession(Session session) {
    _sessions.add(session);
  }

  void removeSession(Session session) {
    _sessions.remove(session);
  }

  // ====== Utilities ======
  /// Format timestamp to readable string (YYYY-MM-DD HH:MM).
  String formatTimestamp(int timestamp) {
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
