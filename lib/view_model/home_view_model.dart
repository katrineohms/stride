import '../model/clients.dart';

class HomeViewModel {
  // ======= Client List =======
  final List<Client> _clients;

  // ======= Calendar State =======
  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;

  // ======= Constructor =======
  HomeViewModel({List<Client>? initialClients})
    : _clients = initialClients ?? [];

  // ======= Public Accessors =======
  List<Client> get clients => _clients;

  // ======= Actions =======

  /// Add a new client to the list
  void addClient(Client client) {
    _clients.add(client);
  }

  /// Update selected and focused day
  void selectDay(DateTime day) {
    selectedDay = day;
    focusedDay = day;
  }

  /// Get clients who have an appointment on the given day
  List<Client> getClientsForDay(DateTime day) {
    return _clients.where((client) {
      // Check if any of the client's appointments fall on the given day
      return client.appointments.any((appointment) {
        final appointmentDate = DateTime.fromMillisecondsSinceEpoch(
          appointment.timestamp * 1000,
        );
        return appointmentDate.year == day.year &&
            appointmentDate.month == day.month &&
            appointmentDate.day == day.day;
      });
    }).toList();
  }
}
