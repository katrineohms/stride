// Packages
import 'dart:async';
import 'dart:developer' show log;
import 'package:flutter/foundation.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

// Files
import '../model/_models.dart';
import '../view_model/movesense_connect_view_model.dart';
import 'widgets_view_model/ui_event.dart';

// Services
import '../service/client_data_service.dart';
import '../service/session_service.dart';
import '../service/movesense_service.dart';

/// ViewModel for session detail view - manages a specific session execution
class SessionDetailViewModel extends ChangeNotifier {
  final Client client;
  final Session session;
  final MovesenseConnectViewModel movesense;
  final UiEventNotifier events;

  final ClientDataService _dataService = ClientDataService();
  final SessionService _sessionService = SessionService();
  bool _attached = false;
  Timer? _uiTicker;

  // Tracks completed exercise IDs for the targeted session
  final Set<String> _completedExerciseIds = <String>{};

  SessionDetailViewModel({
    required this.client,
    required this.session,
    MovesenseConnectViewModel? movesenseViewModel,
    UiEventNotifier? eventNotifier,
  })  : movesense = movesenseViewModel ?? MovesenseService().viewModel,
        events = eventNotifier ?? UiEventNotifier();

  void attach() {
    if (_attached) return;
    _attached = true;
    _sessionService.addListener(_onSessionChanged);
    _initializeCompletionFromSession();

    // Drive UI updates (e.g., live duration) once per second while attached
    _uiTicker?.cancel();
    _uiTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_attached) notifyListeners();
    });
  }

  void _onSessionChanged() {
    notifyListeners();
  }

  /// Check if there's an active session for this client
  bool get isActiveForClient {
    return _sessionService.hasActiveSession && 
           _sessionService.activeClientId == client.clientId;
  }

  /// Get the current session duration
  Duration? get liveDuration {
    return _sessionService.sessionDuration;
  }

  /// Get the active session or fallback to the provided session
  Session get activeSession {
    return _sessionService.activeSession ?? session;
  }

  /// Whether a given exercise is marked completed for this session
  bool isExerciseDone(String exerciseId) => _completedExerciseIds.contains(exerciseId);

  /// Toggle completed state for an exercise and persist to the backing session
  Future<void> toggleExerciseDone(String exerciseId, bool done) async {
    if (done) {
      _completedExerciseIds.add(exerciseId);
    } else {
      _completedExerciseIds.remove(exerciseId);
    }

    // Persist as a list of exercises performed (subset of client's templates)
    final performed = client.exerciseTemplates
        .where((ex) => _completedExerciseIds.contains(ex.exerciseId))
        .toList(growable: false);

    await _persistSessionExercises(performed);
    notifyListeners();
  }

  Future<void> _persistSessionExercises(List<Exercise> performed) async {
    try {
      // Load latest client to avoid overwriting concurrent updates
      final latest = _dataService.getClientById(client.clientId) ?? client;
      final targetSessionId = (_sessionService.activeSession?.sessionId) ?? session.sessionId;

      final updatedSessions = latest.sessions.map((s) {
        if (s.sessionId == targetSessionId) {
          return s.copyWith(exercisesPerformed: performed);
        }
        return s;
      }).toList();

      final updatedClient = latest.copyWith(sessions: updatedSessions);
      await _dataService.updateClient(updatedClient);
    } catch (e) {
      events.emit(SnackBarEvent('Failed to persist exercises: $e', isError: true));
    }
  }

  void _initializeCompletionFromSession() {
    final source = _sessionService.activeSession ?? session;
    _completedExerciseIds
      ..clear()
      ..addAll(source.exercisesPerformed.map((e) => e.exerciseId));
  }

  /// Get the latest session from the database for this session ID
  Future<Session?> getLatestSession() async {
    try {
      final updatedClient = _dataService.getClientById(client.clientId);
      if (updatedClient != null && updatedClient.sessions.isNotEmpty) {
        // Find the session with matching ID, or return the last one if it matches
        for (final s in updatedClient.sessions) {
          if (s.sessionId == session.sessionId) {
            return s;
          }
        }
      }
    } catch (e) {
      log('Error getting latest session', error: e);
    }
    return null;
  }

  /// Get the latest client data from the database
  Future<Client?> getLatestClient() async {
    try {
      return _dataService.getClientById(client.clientId);
    } catch (e) {
      log('Error getting latest client', error: e);
    }
    return null;
  }

  /// Start HR monitoring for this session
  /// Manages screen awake state, system UI, and initializes exercise completion
  Future<void> startSession() async {
    try {
      // Keep screen on during session
      WakelockPlus.enable();
      
      await _sessionService.startSession(client.clientId, scheduledSession: session);
      _initializeCompletionFromSession();
      events.emit(SnackBarEvent('Session started'));
      notifyListeners();
    } catch (e) {
      events.emit(SnackBarEvent('Failed to start session: $e', isError: true));
    }
  }

  /// Stop HR monitoring and save session data
  /// Restores screen auto-lock and system UI to normal state
  Future<void> stopSession() async {
    try {
      WakelockPlus.disable();
      
      await _sessionService.stopSession();
      events.emit(SnackBarEvent('Session stopped'));
      notifyListeners();
    } catch (e) {
      events.emit(SnackBarEvent('Failed to stop session: $e', isError: true));
    }
  }

  /// Delete this session and return the updated client (if persisted)
  Future<Client?> deleteLatestSession() async {
    try {
      // Work off the latest stored client to avoid overwriting concurrent edits
      final latest = _dataService.getClientById(client.clientId) ?? client;
      final updatedSessions = latest.sessions
          .where((s) => s.sessionId != session.sessionId)
          .toList();

      if (updatedSessions.length == latest.sessions.length) {
        events.emit(const SnackBarEvent('Session not found to delete', isError: true));
        return latest;
      }

      final updatedClient = latest.copyWith(sessions: updatedSessions);
      await _dataService.updateClient(updatedClient);
      events.emit(const SnackBarEvent('Session deleted'));
      notifyListeners();
      return updatedClient;
    } catch (e) {
      events.emit(SnackBarEvent('Failed to delete session: $e', isError: true));
    }
    return null;
  }

  /// Update the session with completed exercises
  Future<void> updateSessionExercises(List<Exercise> completedExercises) async {
    try {
      final updatedSession = session.copyWith(
        exercisesPerformed: completedExercises,
      );
      
      final updatedSessions = client.sessions.map((s) {
        return s.sessionId == session.sessionId ? updatedSession : s;
      }).toList();

      final updatedClient = client.copyWith(sessions: updatedSessions);
      await _dataService.updateClient(updatedClient);
      notifyListeners();
    } catch (e) {
      events.emit(SnackBarEvent('Failed to update exercises: $e', isError: true));
    }
  }

  @override
  void dispose() {
    _sessionService.removeListener(_onSessionChanged);
    _uiTicker?.cancel();
    events.dispose();
    super.dispose();
  }
}
