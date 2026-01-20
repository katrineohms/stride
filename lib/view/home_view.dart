// Packages
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

// Files
import '../view/client_list_view.dart';
import 'client_detail_view.dart';
import '../view_model/home_view_model.dart';
import '../view_model/client_detail_view_model.dart';
import '../view/movesense_connect_view.dart';

// Widgets
import '../widgets/client_card_widget.dart';
import '../widgets/movesense_status_widget.dart';



class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // ======= ViewModel =======
  late HomeViewModel viewModel;

  // ======= Lifecycle =======
  @override
  void initState() {
    super.initState();

    // Initialize view model (dummy data is handled by data service)
    viewModel = HomeViewModel();
  }

  // ======= Build UI =======
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ======= AppBar =======
      appBar: AppBar(
        title: const Text('Stride'),
        actions: [
          ListenableBuilder(
            listenable: viewModel.movesense,
            builder: (context, _) {
              return MovesenseStatusIcon(
                connected: viewModel.movesense.isConnected,
                heartRate: 0,
                heartRateStream: viewModel.movesense.heartRateStream,
              );
            },
          ),
        ],
      ),

      // ======= Drawer / Hamburger Menu =======
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: const Text(
                'Clients',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            // Client list in drawer
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
                      builder: (context) => ClientDetailPage(
                        viewModel: ClientDetailViewModel(client: client),
                      ),
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),

      // ======= Body =======
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ======= Header =======
            const Text(
              'Welcome',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // ======= Client List Button =======
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
                          final tween = Tween(
                            begin: const Offset(0, 1),
                            end: Offset.zero,
                          ).chain(CurveTween(curve: Curves.easeOutQuad));

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
            const SizedBox(height: 4),

            // ======= WhatsApp Button =======
            //ElevatedButton.icon(
            //onPressed: () {
            // TO DO: handle WhatsApp action
            //},
            //icon: const Icon(Icons.message),
            //label: const Text('WhatsApp'),
            //),
            //const SizedBox(height: 4),

            // ======= Movesense Status =======
            ListenableBuilder(
              listenable: viewModel.movesense,
              builder: (context, _) {
                return MoveSenseStatusCard(
                  connected: viewModel.movesense.isConnected,
                  heartRate: 0,
                  heartRateStream: viewModel.movesense.heartRateStream,
                  batteryOk: true,
                  batteryStream: viewModel.movesense.batteryStream,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MovesenseConnectView(
                          viewModel: viewModel.movesense,
                        ),
                      ),
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 4),

            // ======= Calendar =======
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: viewModel.focusedDay,
              selectedDayPredicate: (day) =>
                  isSameDay(viewModel.selectedDay ?? DateTime.now(), day),
              eventLoader: (day) => viewModel.getClientsForDay(day),
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
              calendarStyle: CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.35),
                  shape: BoxShape.circle,
                ),
              ),
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, day, events) {
                  if (events.isEmpty) return const SizedBox.shrink();
                  final isSelected =
                      isSameDay(viewModel.selectedDay ?? DateTime.now(), day);
                  return Positioned(
                    bottom: 10,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white
                            : Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // ======= Clients for Selected Day =======
            Builder(
              builder: (context) {
                final selectedDay = viewModel.selectedDay ?? DateTime.now();
                final clientsForDay = viewModel.getClientsForDay(selectedDay);

                if (clientsForDay.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'No sessions scheduled today',
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  );
                }

                return Column(
                  children: clientsForDay.map((client) {
                    return ClientCard(
                      client: client,
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
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
