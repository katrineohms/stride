import '../model/clients.dart';

class HomeViewModel {
  final List<Client> _clients;

  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;

  HomeViewModel({List<Client>? initialClients})
      : _clients = initialClients ?? [];

  List<Client> get clients => _clients;

  void addClient(Client client) {
    _clients.add(client);
  }

  void selectDay(DateTime day) {
    selectedDay = day;
    focusedDay = day;
  }

  List<Client> getClientsForDay(DateTime day) {
    // Replace with real logic for filtering by day
    if (selectedDay != null) return _clients;
    return [];
  }
}
