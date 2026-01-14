import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'widgets/client_card_widget.dart';
import 'package:stride/view/client_list_view.dart';
import 'package:stride/model/clients.dart';
import 'package:stride/view/client_card_view.dart';
import 'package:stride/view_model/home_view_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late HomeViewModel viewModel;

  @override
  void initState() {
    super.initState();

    // Initialize view model with dummy clients
    viewModel = HomeViewModel(initialClients: [
      Client(
        clientId: '1',
        name: 'AnnaDummy',
        age: 25,
        gender: 'Female',
        active: 0,
        nextAppointment: 1672531200,
        motivation: 'Motivated',
      ),
      Client(
        clientId: '2',
        name: 'MarkDummy',
        age: 30,
        gender: 'Male',
        active: 1,
        nextAppointment: 1672531200,
        motivation: 'Needs support',
      ),
      Client(
        clientId: '3',
        name: 'SophiaDummy',
        age: 28,
        gender: 'Female',
        active: 2,
        nextAppointment: 1672531200,
        motivation: 'Struggling',
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stride'),
      ),

      // Hamburger menu
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 97, 164, 97),
              ),
              child: Text(
                'Clients',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ...viewModel.clients.map((client) {
              return ListTile(
                leading: const Icon(Icons.person),
                title: Text(client.name),
                trailing: Icon(
                  Icons.circle, 
                  color: getStatusColor(client.active),
                ),
                onTap: () {
                  Navigator.pop(context); // close drawer
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ClientDetailPage(client: client),
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Welcome',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            // Client list button
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 400),
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        ClientOverviewPage(clients: viewModel.clients),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      final tween =
                          Tween(begin: const Offset(0, 1), end: Offset.zero)
                              .chain(CurveTween(curve: Curves.easeOutQuad));

                      return SlideTransition(
                        position: animation.drive(tween),
                        child: child,
                      );
                    },
                  ),
                );
              },
              icon: const Icon(Icons.people),
              label: const Text('Client list'),
            ),

            const SizedBox(height: 8),

            // WhatsApp button
            ElevatedButton.icon(
              onPressed: () {
                // TODO: handle WhatsApp action
              },
              icon: const Icon(Icons.message),
              label: const Text('WhatsApp'),
            ),

            const SizedBox(height: 24),

            // Calendar
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: viewModel.focusedDay,
              selectedDayPredicate: (day) =>
                  isSameDay(viewModel.selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  viewModel.selectDay(selectedDay);
                });
              },
              onPageChanged: (focusedDay) {
                viewModel.focusedDay = focusedDay;
              },
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
            ),

            const SizedBox(height: 16),

            // Clients for the day
            ...viewModel.getClientsForDay(viewModel.selectedDay ?? DateTime.now())
                .map((client) {
              return ClientCard(
                client: client,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ClientDetailPage(client: client),
                    ),
                  );
                },
              );
            }),
          ],
        ),
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
