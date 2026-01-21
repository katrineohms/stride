// Packages
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:share_plus/share_plus.dart';

// Files
import '../view/client_list_view.dart';
import 'client_detail_view.dart';
import 'session_detail_view.dart';
import '../view_model/home_view_model.dart';
import '../view_model/client_detail_view_model.dart';
import '../view_model/session_detail_view_model.dart';
import '../view/movesense_connect_view.dart';

// Widgets
import '../widgets/client_card_widget.dart';
import '../widgets/movesense_status_widget.dart';

/// ============================================
/// HOME PAGE
/// ============================================
/// Main landing page of the app featuring:
/// - Welcome header
/// - Client list navigation button
/// - Movesense device connection status
/// - Calendar with session indicators
/// - Clients scheduled for selected day
/// - Hamburger menu with client list and data export
/// - Navigation to client details and session views

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // ======= State =======
  late HomeViewModel viewModel;

  // ======= Lifecycle Methods =======
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
      // ======= App Bar =======
      appBar: AppBar(
        title: const Text('Stride'),
        actions: [
          MovesenseAppBarStatus(viewModel: viewModel.movesense),
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
            // Export data option
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Export & Share Data'),
              onTap: () async {
                Navigator.pop(context); // close drawer
                
                // Show loading indicator
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
                
                try {
                  final file = await viewModel.exportDataToJson();
                  
                  // Close loading indicator
                  if (context.mounted) Navigator.pop(context);
                  
                  // Share the file
                  await Share.shareXFiles(
                    [XFile(file.path)],
                    subject: 'Stride HR Data Export',
                    text: 'Heart rate monitoring data from Stride app',
                  );
                } catch (e) {
                  // Close loading indicator
                  if (context.mounted) Navigator.pop(context);
                  
                  // Show error message
                  if (context.mounted) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Export Failed'),
                        content: Text('Error: $e'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  }
                }
              },
            ),
            const Divider(),
            // ======= Client List in Drawer =======
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
      /// Main scrollable content area
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

            // ======= Movesense Status =======
            /// Shows connection status and battery level
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
            /// Interactive calendar with session markers
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
            /// Displays client cards for sessions on the selected calendar day
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
                    // Retrieve or construct a session object for the selected day via ViewModel
                    final sessionForDay = viewModel.ensureSessionForDay(client, selectedDay);

                    return ClientCard(
                      client: client,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SessionDetailPage(
                              viewModel: SessionDetailViewModel(
                                client: client,
                                session: sessionForDay,
                              ),
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
