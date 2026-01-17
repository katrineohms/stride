import '../model/clients.dart';
import 'package:flutter/material.dart';

class ClientOverviewViewModel {
  final List<Client> _clients;

  ClientOverviewViewModel({List<Client>? initialClients})
      : _clients = initialClients ?? [];

  // Expose clients as read-only
  List<Client> get clients => List.unmodifiable(_clients);

  // Add a new client
  void addClient(Client client) {
    _clients.add(client);
  }

  // TO DO search/filter clients by name
  List<Client> searchClients(String query) {
    if (query.isEmpty) return clients;
    return _clients
        .where((c) => c.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // in ClientOverviewViewModel
  Color getStatusColor(int active) {
    switch (active) {
      case 0:
        return Colors.green;
      case 1:
        return Colors.yellow;
      case 2:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}



