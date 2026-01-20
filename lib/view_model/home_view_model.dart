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
    if (initialClients != null && initialClients.isNotEmpty) {
      // Initialize with provided clients
      _dataService.clear();
      for (final client in initialClients) {
        _dataService.addClient(client);
      }
    } else {
      // Use dummy data by default
      _dataService.initializeDummyData();
    }
  }

  // ======= Public Accessors =======
  List<Client> get clients => _dataService.getClients();

  // ======= Actions =======

  /// Add a new client to the list
  void addClient(Client client) {
    _dataService.addClient(client);
  }

  /// Update an existing client
  void updateClient(Client client) {
    _dataService.updateClient(client);
  }

  /// Delete a client
  void deleteClient(String clientId) {
    _dataService.deleteClient(clientId);
  }

  /// Update selected and focused day
  void selectDay(DateTime day) {
    selectedDay = day;
    focusedDay = day;
  }

  /// Get clients who have an appointment on the given day
  List<Client> getClientsForDay(DateTime day) {
    return _dataService.getClientsForDay(day);
  }

  /// Search clients by name
  List<Client> searchClients(String query) {
    return _dataService.searchClients(query);
  }
}
