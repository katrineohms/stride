import 'package:flutter/material.dart';
import '../model/clients.dart';
import '../widgets/client_card_widget.dart'; // <-- import helper

class ClientOverviewViewModel {
  final List<Client> _clients;

  ClientOverviewViewModel({List<Client>? initialClients})
      : _clients = initialClients ?? [];

  List<Client> get clients => List.unmodifiable(_clients);

  void addClient(Client client) {
    _clients.add(client);
  }

  List<Client> searchClients(String query) {
    if (query.isEmpty) return clients;
    return _clients
        .where((c) => c.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // Example method using getStatusColor
  Color getClientStatusColor(Client client) {
    return getStatusColor(client.active); // call the helper here
  }
}
