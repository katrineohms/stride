// Packages
import 'dart:developer' show log;
import 'package:flutter/foundation.dart';

// Files
import '../model/_models.dart';
import '../view_model/movesense_connect_view_model.dart';
import 'widgets_view_model/ui_event.dart';

// Services
import '../service/client_data_service.dart';
import '../service/movesense_service.dart';
import '../service/session_service.dart';

/// ViewModel for the Client Detail Page
class ClientDetailViewModel extends ChangeNotifier {
  ClientDetailViewModel({
    required Client client,
    MovesenseConnectViewModel? movesense,
    UiEventNotifier? events,
  })  : _client = client,
        movesense = movesense ?? MovesenseService().viewModel,
        events = events ?? UiEventNotifier();

  final ClientDataService _dataService = ClientDataService();
  final SessionService _sessionService = SessionService();
  final MovesenseConnectViewModel movesense;
  final UiEventNotifier events;
  Client _client;
  bool _attached = false;

  // Public accessor for SessionService
  SessionService get sessionService => _sessionService;

  void _onSessionChanged() => notifyListeners();

  void attach() {
    if (_attached) return;
    _sessionService.addListener(_onSessionChanged);
    _attached = true;
  }

  void detach() {
    if (!_attached) return;
    _sessionService.removeListener(_onSessionChanged);
    _attached = false;
  }

  Client get client => _client;

  // ===== Session Filtering =====
  /// Returns completed sessions sorted by end time (most recent first)
  List<Session> get previousSessions {
    return _client.sessions
        .where((s) => s.endTime != null)
        .toList()
      ..sort((a, b) => b.endTime!.compareTo(a.endTime!));
  }

  /// Returns scheduled sessions (no end time) sorted by start time
  List<Session> get upcomingSessions {
    return _client.sessions
        .where((s) => s.endTime == null)
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  // ===== Client Data Refresh =====
  Future<Client?> getLatestClient() async {
    try {
      return _dataService.getClientById(_client.clientId);
    } catch (e) {
      log('Error getting latest client', error: e);
    }
    return null;
  }

  // ===== Next Scheduled Session =====
  /// Returns the soonest future session by scheduled startTime
  Session? get nextSession {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final futureSessions = _client.sessions
        .where((s) => s.startTime >= now && s.endTime == null)
        .toList();
    if (futureSessions.isEmpty) return null;
    futureSessions.sort((a, b) => a.startTime.compareTo(b.startTime));
    return futureSessions.first;
  }

  /// Formatted string for the next session (YYYY-MM-DD HH:MM)
  String get nextSessionFormatted {
    final session = nextSession;
    if (session == null) return 'No upcoming session';

    final dt = DateTime.fromMillisecondsSinceEpoch(session.startTime * 1000);
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    final dateStr = dt.toLocal().toIso8601String().split('T')[0];

    return '$dateStr $hour:$minute';
  }

  /// Exercise templates remain tied to the client
  List<Exercise> get exerciseTemplates => _client.exerciseTemplates;

  /// Refresh client from data store
  Future<void> refreshClient() async {
    final refreshed = _dataService.getClientById(_client.clientId);
    if (refreshed != null) {
      _client = refreshed;
      notifyListeners();
    }
  }

  /// Update the client and optionally persist
  Future<void> updateClient(Client updatedClient, {bool persist = true}) async {
    _client = updatedClient;
    if (persist) {
      await _dataService.updateClient(_client);
    }
    notifyListeners();
  }

  /// Remove the latest session (used by UI delete button)
  Future<void> deleteLatestSession() async {
    if (_client.sessions.isEmpty) return;
    final updatedSessions = List<Session>.from(_client.sessions)..removeLast();
    await updateClient(_client.copyWith(sessions: updatedSessions));
  }

  /// Delete a specific session
  Future<void> deleteSession(Session session) async {
    final updatedSessions = _client.sessions
        .where((s) => s.sessionId != session.sessionId)
        .toList();
    await updateClient(_client.copyWith(sessions: updatedSessions));
  }

  /// Quick start a session (creates new session immediately)
  Future<void> startSession() async {
    if (_sessionService.hasActiveSession &&
        _sessionService.activeClientId != _client.clientId) {
      events.emit(
        const SnackBarEvent(
          'Another session is active. Stop it first.',
          isError: true,
        ),
      );
      return;
    }
    try {
      // Quick start - no scheduled session
      await _sessionService.startSession(_client.clientId);
      events.emit(const SnackBarEvent('Session started!'));
    } catch (e) {
      events.emit(
        SnackBarEvent('Could not start session: $e', isError: true),
      );
    }
  }

  /// Stop session and refresh client data from the data service.
  Future<void> stopSessionAndRefresh() async {
    try {
      await _sessionService.stopSession();
      final refreshed = _dataService.getClientById(_client.clientId);
      if (refreshed != null) {
        await updateClient(refreshed, persist: false);
      }
      events.emit(const SnackBarEvent('Session stopped and saved.'));
    } catch (e) {
      events.emit(
        SnackBarEvent('Could not stop session: $e', isError: true),
      );
    }
  }

  bool get isSessionActiveForClient =>
      _sessionService.hasActiveSession &&
      _sessionService.activeClientId == _client.clientId;

  Duration? get sessionDuration => _sessionService.sessionDuration;

  int? get currentSessionHeartRate => _sessionService.currentHeartRate;

  /// Create a new scheduled session and add it to the client
  Future<void> addScheduledSession(Session session) async {
    final updatedSessions = List<Session>.from(_client.sessions)..add(session);
    await updateClient(_client.copyWith(sessions: updatedSessions));
    events.emit(const SnackBarEvent('Session scheduled!'));
  }

  @override
  void dispose() {
    detach();
    events.dispose();
    super.dispose();
  }
}
