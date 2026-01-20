// Packages
import 'package:flutter/foundation.dart';

// Files
import '../model/clients.dart';
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

  // ===== Next Appointment =====
  /// Returns the soonest future appointment, or null if none
  Appointment? get nextAppointment {
    final upcoming = _client.upcomingAppointments;
    return upcoming.isEmpty ? null : upcoming.first.appointment;
  }

  /// Formatted string for the next appointment (YYYY-MM-DD HH:MM)
  String get nextAppointmentFormatted {
    final appointment = nextAppointment;
    if (appointment == null) return 'No upcoming appointment';

    final dt = DateTime.fromMillisecondsSinceEpoch(appointment.timestamp * 1000);
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    final dateStr = dt.toLocal().toIso8601String().split('T')[0];

    return '$dateStr $hour:$minute';
  }

  /// Exercise templates for this client
  List<Exercise> get exerciseTemplates => _client.exerciseTemplates;

  /// Get exercises from the active session, if any
  List<Exercise> get activeSessionExercises {
    if (!isSessionActiveForClient || _sessionService.activeSession == null) {
      return const [];
    }
    return _sessionService.activeSession!.exercises;
  }

  /// Update the client and optionally persist
  Future<void> updateClient(Client updatedClient, {bool persist = true}) async {
    _client = updatedClient;
    if (persist) {
      await _dataService.updateClient(_client);
    }
    notifyListeners();
  }

  /// Replace/merge HRR results in the latest session and persist
  Future<void> setHeartRateRecovery(String exerciseId, HeartRateRecovery hrr) async {
    if (_client.sessions.isEmpty) return;
    
    final latestSession = _client.sessions.last;
    final updatedHrr = Map<String, HeartRateRecovery>.from(latestSession.hrrResults)
      ..[exerciseId] = hrr;
    
    final updatedSession = latestSession.copyWith(hrrResults: updatedHrr);
    final updatedSessions = List<Session>.from(_client.sessions)
      ..[_client.sessions.length - 1] = updatedSession;
    
    await updateClient(_client.copyWith(sessions: updatedSessions));
  }

  /// Remove the latest session (used by UI delete button)
  Future<void> deleteLatestSession() async {
    if (_client.sessions.isEmpty) return;
    final updatedSessions = List<Session>.from(_client.sessions)..removeLast();
    await updateClient(_client.copyWith(sessions: updatedSessions));
  }

  /// Start a session and emit UI events for success or failure.
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

  @override
  void dispose() {
    detach();
    events.dispose();
    super.dispose();
  }
}
