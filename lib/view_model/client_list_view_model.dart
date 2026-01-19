import 'package:flutter/material.dart';
import '../model/clients.dart';
import '../service/client_data_service.dart';
import '../widgets/client_card_widget.dart'; // <-- import helper

class ClientOverviewViewModel {
  final ClientDataService _dataService = ClientDataService();

  ClientOverviewViewModel({List<Client>? initialClients}) {
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
