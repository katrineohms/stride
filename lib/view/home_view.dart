import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'widgets/client_card_widget.dart';
import 'package:stride/view/client_list_view.dart';
import 'package:stride/model/clients.dart';
import 'package:stride/view/client_card_view.dart';

// TODO integrate with backend
// TODO save data persistently

void main() {
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stride',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 97, 164, 97)),
        useMaterial3: true,

        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 97, 164, 97),
          foregroundColor: Colors.white, // title & icons
          centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 30,
          //fontFamily: 'Roboto', TODO import font
          fontWeight: FontWeight.bold,
          color: Colors.white,),
        ),
      ),
      home: const HomePage(),
    );
  }
}



class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Client> _dummyClients = [
    Client(clientId: '1', name: 'AnnaDummy', age: 25, gender: 'Female', active: 0, nextAppointment: 1672531200, motivation: 'Motivated'),
    Client(clientId: '2', name: 'MarkDummy', age: 30, gender: 'Male', active: 1, nextAppointment: 1672531200, motivation: 'Needs support'),
    Client(clientId: '3', name: 'SophiaDummy', age: 28, gender: 'Female', active: 2, nextAppointment: 1672531200, motivation: 'Struggling'),
  ];


  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  List<Client> getClientsForDay(DateTime day) {
    // TODO replace with real logic
    if (_selectedDay != null) {
      return _dummyClients;
    }
    return [];
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stride'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
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

            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 400),
                    pageBuilder: (context, animation, secondaryAnimation) => ClientOverviewPage(
                      clients: _dummyClients,
                    ),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      // Slide from bottom
                      final tween = Tween(begin: const Offset(0, 1), end: Offset.zero)
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

            ElevatedButton.icon(
              onPressed: () {
                // TODO handle button press
              },
              icon: const Icon(Icons.message),
              label: const Text('WhatsApp'),
            ),

            const SizedBox(height: 24),

            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,

              selectedDayPredicate: (day) =>
                isSameDay(_selectedDay, day),

              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },

              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },


              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
            ),

            const SizedBox(height: 16),

            ...getClientsForDay(_selectedDay!).map((client) {
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

