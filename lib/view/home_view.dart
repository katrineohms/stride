import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';



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
          centerTitle: true,),
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
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stride'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome 👋',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                // TODO center
              ),
            ),

            const SizedBox(height: 8),

            ElevatedButton.icon(
              onPressed: () {
                // TODO handle button press
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


            // TODO client cards for the day


          ],
        ),
      ),
    );
  }
}
