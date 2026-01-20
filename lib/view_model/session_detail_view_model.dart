// Packages
import 'package:flutter/foundation.dart';

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

  /// Start HR monitoring for this session
  Future<void> startSession() async {
    try {
      await _sessionService.startSession(client.clientId);
      events.emit(SnackBarEvent('Session started'));
      notifyListeners();
    } catch (e) {
      events.emit(SnackBarEvent('Failed to start session: $e', isError: true));
    }
  }

  /// Stop HR monitoring and save session data
  Future<void> stopSession() async {
    try {
      await _sessionService.stopSession();
      events.emit(SnackBarEvent('Session stopped'));
      notifyListeners();
    } catch (e) {
      events.emit(SnackBarEvent('Failed to stop session: $e', isError: true));
    }
  }

  /// Delete the latest session for this client
  Future<void> deleteLatestSession() async {
    try {
      final updatedSessions = client.sessions.toList();
      if (updatedSessions.isNotEmpty) {
        updatedSessions.removeLast();
      }
      final updatedClient = client.copyWith(sessions: updatedSessions);
      await _dataService.updateClient(updatedClient);
      events.emit(SnackBarEvent('Session deleted'));
      notifyListeners();
    } catch (e) {
      events.emit(SnackBarEvent('Failed to delete session: $e', isError: true));
    }
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
    events.dispose();
    super.dispose();
  }
}
