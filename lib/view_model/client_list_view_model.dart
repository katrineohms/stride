import 'dart:async';

// Packages
import 'package:flutter/material.dart';

// Files
import '../model/_models.dart';
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
    unawaited(_dataService.init());
  }

  List<Client> get clients => _dataService.getClients();

  Future<void> addClient(Client client) async {
    await _dataService.addClient(client);
  }

  Future<void> updateClient(Client client) async {
    await _dataService.updateClient(client);
  }

  Future<void> deleteClient(String clientId) async {
    await _dataService.deleteClient(clientId);
  }


  // Example method using getStatusColor
  Color getClientStatusColor(Client client) {
    return getStatusColor(client.active); // call the helper here
  }
}
