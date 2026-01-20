// Packages
import 'package:flutter/material.dart';

// Files
import '../model/clients.dart';
import '../view_model/movesense_connect_view_model.dart';

// Widgets
import '../widgets/client_card_widget.dart';

// Services
import '../service/client_data_service.dart';
import '../service/movesense_service.dart';

class ClientOverviewViewModel {
  final ClientDataService _dataService = ClientDataService();
  final MovesenseConnectViewModel movesense;

  ClientOverviewViewModel({
    List<Client>? initialClients,
    MovesenseConnectViewModel? movesense,
  }) : movesense = movesense ?? MovesenseService().viewModel {
    if (initialClients != null && initialClients.isNotEmpty) {
      _dataService.clear();
      for (final client in initialClients) {
        _dataService.addClient(client);
      }
    }
  }

  List<Client> get clients => _dataService.getClients();

  void addClient(Client client) {
    _dataService.addClient(client);
  }

  void updateClient(Client client) {
    _dataService.updateClient(client);
  }

  void deleteClient(String clientId) {
    _dataService.deleteClient(clientId);
  }

  List<Client> searchClients(String query) {
    return _dataService.searchClients(query);
  }

  // Example method using getStatusColor
  Color getClientStatusColor(Client client) {
    return getStatusColor(client.active); // call the helper here
  }
}
