// Packages
import 'package:flutter/material.dart';

// Files
import '../model/_models.dart';
import '../view/create_client_view.dart';
import 'client_detail_view.dart';
import '../view_model/client_list_view_model.dart';
import '../view_model/client_detail_view_model.dart';

// Widgets
import '../widgets/client_card_widget.dart';
import '../widgets/movesense_status_widget.dart';

/// ============================================
/// CLIENT OVERVIEW PAGE
/// ============================================
/// Displays a scrollable list of all clients in the system with:
/// - Client creation button
/// - Client cards showing name and status
/// - Navigation to individual client detail pages
/// - Movesense connection status indicator

/// Page displaying a list of all clients
class ClientOverviewPage extends StatefulWidget {
  final List<Client> clients;

  const ClientOverviewPage({super.key, required this.clients});

  @override
  State<ClientOverviewPage> createState() => _ClientOverviewPageState();
}

class _ClientOverviewPageState extends State<ClientOverviewPage> {
  late ClientOverviewViewModel viewModel;

  // ======= Lifecycle Methods =======
  @override
  void initState() {
    super.initState();
    // Initialize view model with provided clients
    viewModel = ClientOverviewViewModel(initialClients: widget.clients);
  }

  // ======= Build UI =======
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ======= App Bar =======
      appBar: AppBar(
        title: const Text('Clients'),
        centerTitle: true,
        actions: [
          MovesenseAppBarStatus(viewModel: viewModel.movesense),
        ],
      ),
      // ======= Body: Scrollable Client List =======
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ======= Create Client Button =======
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

          // ======= Client Cards =======
          /// Maps each client to a card with avatar, name, and status
          ...viewModel.clients.map((client) {
            return Card(
              color: Theme.of(context).cardColor,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
                  color: getStatusColor(client.active),
                ),
                // Tap handler
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
