import 'dart:async';

// ===============================
// Files
// ===============================
import '../model/_models.dart';
import '../view_model/movesense_connect_view_model.dart';

// ===============================
// Services
// ===============================
import '../service/client_data_service.dart';
import '../service/movesense_service.dart';

// ===============================
// ClientOverviewViewModel
// ===============================
class ClientOverviewViewModel {
  // ====== Private Fields ======
  final ClientDataService _dataService = ClientDataService();
  final MovesenseConnectViewModel movesense;

  // ====== Constructor ======
  ClientOverviewViewModel({
    List<Client>? initialClients,
    MovesenseConnectViewModel? movesense,
  }) : movesense = movesense ?? MovesenseService().viewModel {
    unawaited(_dataService.init());
  }

  // ====== Public Getters ======
  List<Client> get clients => _dataService.getClients();

  // ====== Client Management ======
  Future<void> addClient(Client client) async {
    await _dataService.addClient(client);
  }

  Future<void> updateClient(Client client) async {
    await _dataService.updateClient(client);
  }

  Future<void> deleteClient(String clientId) async {
    await _dataService.deleteClient(clientId);
  }
}
