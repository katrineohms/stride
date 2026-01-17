import 'package:flutter/material.dart';
import 'package:stride/model/clients.dart';

import 'package:stride/view/create_client_view.dart';
import 'package:stride/view/client_card_view.dart';
import 'package:stride/view_model/client_list_view_model.dart';

/// Page displaying a list of all clients
class ClientOverviewPage extends StatefulWidget {
  final List<Client> clients;

  const ClientOverviewPage({super.key, required this.clients});

  @override
  State<ClientOverviewPage> createState() => _ClientOverviewPageState();
}

class _ClientOverviewPageState extends State<ClientOverviewPage> {
  late ClientOverviewViewModel viewModel;

  @override
  void initState() {
    super.initState();
    // Initialize view model with provided clients
    viewModel = ClientOverviewViewModel(initialClients: widget.clients);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clients'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ======= Action Buttons =======
          // Create client button
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateClientPage(
                    onCreate: (newClient) {
                      setState(() {
                        viewModel.addClient(newClient);
                      });
                    },
                  ),
                ),
              );
            },
            label: const Text('Create Client'),
            icon: const Icon(Icons.add),
          ),
          const SizedBox(height: 8),

          // Search button (placeholder)
          //ElevatedButton.icon(
            //onPressed: () {
              // TO DO: implement search functionality
            //},
            //label: const Text('Search'),
            //icon: const Icon(Icons.search),
          //),
          //const SizedBox(height: 16),

          // ======= Client List =======
          ...viewModel.clients.map((client) {
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                // Avatar
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    client.name[0],
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                // Name
                title: Text(client.name),
                // Status indicator
                trailing: Icon(
                  Icons.circle,
                  color: viewModel.getStatusColor(client.active),
                ),
                // Tap to view details
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ClientDetailPage(
                        viewModel: ClientDetailViewModel(client: client),
                      ),
                    ),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}
