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

  /// Get clients for a specific day (placeholder logic)
  List<Client> getClientsForDay(DateTime day) {
    // TODO: Replace with real filtering logic by date
    if (selectedDay != null) return _clients;
    return [];
  }
}
