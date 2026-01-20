import 'dart:async';

// Files
import '../model/clients.dart';
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
}
