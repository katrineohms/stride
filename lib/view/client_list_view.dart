import 'package:flutter/material.dart';
import 'package:stride/model/clients.dart';
import 'package:stride/view/create_client_view.dart';
import 'package:stride/view/client_card_view.dart';
// import 'widgets/client_card_widget.dart'; // reuse your client card if you want


class ClientOverviewPage extends StatefulWidget {
  final List<Client> clients;

  const ClientOverviewPage({super.key, required this.clients});

  @override
  State<ClientOverviewPage> createState() => _ClientOverviewPageState();
}


class _ClientOverviewPageState extends State<ClientOverviewPage> {
  late List<Client> clients;

  @override
  void initState() {
    super.initState();
    clients = List.from(widget.clients); // copy initial clients
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
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreateClientPage(
                        onCreate: (newClient) {
                          setState(() {
                            clients.add(newClient); // add new client to list
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
          ElevatedButton.icon(
            onPressed: () {
              // TODO handle search
            },
            label: const Text('Search'),
            icon: const Icon(Icons.search),
          ),
          const SizedBox(height: 16),

          // Map your clients to cards
          ...clients.map((client) {
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    client.name[0],
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(client.name),
                trailing: Icon(
                  Icons.circle,
                  color: getStatusColor(client.active),
                ),
                onTap: () {  
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ClientDetailPage(client: client),
                    ),
                  );
                  },
              ),
            );
          }).toList(),
        ],
      ),

    );
  }
}

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
