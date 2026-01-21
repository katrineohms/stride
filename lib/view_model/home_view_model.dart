import 'dart:async';
import 'dart:io';

// Files
import '../model/_models.dart';
import '../view_model/movesense_connect_view_model.dart';

// Services
import '../service/client_data_service.dart';
import '../service/movesense_service.dart';

class HomeViewModel {
  // ======= Dependencies =======
  final ClientDataService _dataService = ClientDataService();
  final MovesenseConnectViewModel movesense;

  // ======= Calendar State =======
  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;

  // ======= Constructor =======
  HomeViewModel({
    List<Client>? initialClients,
    MovesenseConnectViewModel? movesense,
  }) : movesense = movesense ?? MovesenseService().viewModel {
    unawaited(_dataService.init());
  }

  // ======= Public Accessors =======
  List<Client> get clients => _dataService.getClients();

  // ======= Actions =======

  /// Add a new client to the list
  Future<void> addClient(Client client) async {
    await _dataService.addClient(client);
  }

  /// Update an existing client
  Future<void> updateClient(Client client) async {
    await _dataService.updateClient(client);
  }

  /// Delete a client
  Future<void> deleteClient(String clientId) async {
    await _dataService.deleteClient(clientId);
  }

  /// Update selected and focused day
  void selectDay(DateTime day) {
    selectedDay = day;
    focusedDay = day;
  }

  /// Get clients who have a session on the given day
  List<Client> getClientsForDay(DateTime day) {
    return _dataService.getClientsForDay(day);
  }

  /// Export all data to JSON file
  Future<File> exportDataToJson() async {
    return await _dataService.dumpToJson();
  }

  // ======= Session Helpers =======
  /// Return all sessions for a client on the given day
  List<Session> getSessionsForDay(Client client, DateTime day) {
    final dayStart = DateTime(day.year, day.month, day.day)
            .millisecondsSinceEpoch ~/
        1000;
    final dayEnd = DateTime(day.year, day.month, day.day, 23, 59, 59)
            .millisecondsSinceEpoch ~/
        1000;

    final sessions = client.sessions
        .where((s) => s.startTime >= dayStart && s.startTime <= dayEnd)
        .toList();
    
    if (sessions.isEmpty) {
      // No session found for the day; create a placeholder
      return [
        Session(
          sessionId: '${client.clientId}_$dayStart',
          startTime: dayStart,
          hrReadings: const [],
          exercisesPerformed: const [],
        ),
      ];
    }
    
    return sessions;
  }

  /// Return an existing session for the given day or a placeholder session
  /// starting at the beginning of that day if none exists.
  Session ensureSessionForDay(Client client, DateTime day) {
    return getSessionsForDay(client, day).first;
  }
}
