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
  Session latestSession;
  final MovesenseConnectViewModel movesense;
  final UiEventNotifier events;

  final ClientDataService _dataService = ClientDataService();
  final SessionService _sessionService = SessionService();
  bool _attached = false;

  SessionDetailViewModel({
    required this.client,
    required Session session,
    MovesenseConnectViewModel? movesenseViewModel,
    UiEventNotifier? eventNotifier,
  })  : movesense = movesenseViewModel ?? MovesenseService().viewModel,
        events = eventNotifier ?? UiEventNotifier(),
        latestSession = session;

  void attach() {
    if (_attached) return;
    _sessionService.addListener(_onSessionServiceChanged);
    _attached = true;
  }

  void _onSessionServiceChanged() {
    notifyListeners();
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
      await _refreshLatestSession();
      notifyListeners();
    } catch (e) {
      events.emit(SnackBarEvent('Failed to stop session: $e', isError: true));
    }
  }

  Future<void> _refreshLatestSession() async {
    final refreshed = _dataService.getClientById(client.clientId);
    if (refreshed == null) return;
    final completed = refreshed.sessions.where((s) => s.endTime != null).toList()
      ..sort((a, b) => b.endTime!.compareTo(a.endTime!));
    if (completed.isNotEmpty) {
      latestSession = completed.first;
    }
  }

  /// Save HRR result for a specific exercise
  Future<void> saveHrrResult(String exerciseId, HeartRateRecovery hrr) async {
    try {
      final updatedHrr = Map<String, HeartRateRecovery>.from(latestSession.hrrResults)
        ..[exerciseId] = hrr;
      final updatedSession = latestSession.copyWith(hrrResults: updatedHrr);
      latestSession = updatedSession;
      notifyListeners();
    } catch (e) {
      events.emit(SnackBarEvent('Failed to save HRR: $e', isError: true));
    }
  }

  /// Update the session with completed exercises
  Future<void> updateSessionExercises(List<Exercise> completedExercises) async {
    try {
      final updatedSession = latestSession.copyWith(
        exercisesPerformed: completedExercises,
      );
      
      final updatedSessions = client.sessions.map((s) {
        return s.sessionId == latestSession.sessionId ? updatedSession : s;
      }).toList();

      final updatedClient = client.copyWith(sessions: updatedSessions);
      await _dataService.updateClient(updatedClient);
      latestSession = updatedSession;
      notifyListeners();
    } catch (e) {
      events.emit(SnackBarEvent('Failed to update exercises: $e', isError: true));
    }
  }

  /// Delete the latest session
  Future<void> deleteLatestSession() async {
    try {
      final refreshed = _dataService.getClientById(client.clientId);
      if (refreshed == null) return;
      final updatedSessions = List<Session>.from(refreshed.sessions)..removeLast();
      final updatedClient = refreshed.copyWith(sessions: updatedSessions);
      await _dataService.updateClient(updatedClient);
      
      final completed = updatedClient.sessions.where((s) => s.endTime != null).toList()
        ..sort((a, b) => b.endTime!.compareTo(a.endTime!));
      if (completed.isNotEmpty) {
        latestSession = completed.first;
      }
      notifyListeners();
    } catch (e) {
      events.emit(SnackBarEvent('Failed to delete session: $e', isError: true));
    }
  }

  @override
  void dispose() {
    _sessionService.removeListener(_onSessionServiceChanged);
    events.dispose();
    super.dispose();
  }

  bool get isActiveForClient =>
      _sessionService.hasActiveSession &&
      _sessionService.activeClientId == client.clientId;

  Duration? get liveDuration => _sessionService.sessionDuration;

  int? get liveHeartRate => _sessionService.currentHeartRate;

  Session? get activeSession => _sessionService.activeSession;

  Session get session => latestSession;
}
