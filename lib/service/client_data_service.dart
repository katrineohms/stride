import '../model/clients.dart';

/// ============= Client Data Service =============
/// Centralized service for managing client data.
/// Handles initialization, CRUD operations, and data fetching.
/// 
/// Can be extended to support backend API calls in the future.
class ClientDataService {
  // Singleton instance
  static final ClientDataService _instance = ClientDataService._internal();

  // In-memory storage (replace with database/API later)
  final List<Client> _clients = [];

  // ===== Constructor =====
  ClientDataService._internal();

  factory ClientDataService() {
    return _instance;
  }

  // ===== Public Accessors =====
  /// Get all clients
  List<Client> getClients() => List.from(_clients);

  /// Get a single client by ID
  Client? getClientById(String clientId) {
    try {
      return _clients.firstWhere((c) => c.clientId == clientId);
    } catch (e) {
      return null;
    }
  }

  // ===== CRUD Operations =====
  /// Add a new client
  void addClient(Client client) {
    _clients.add(client);
  }

  /// Update an existing client
  void updateClient(Client updatedClient) {
    final index = _clients.indexWhere((c) => c.clientId == updatedClient.clientId);
    if (index != -1) {
      _clients[index] = updatedClient;
    }
  }

  /// Delete a client
  void deleteClient(String clientId) {
    _clients.removeWhere((c) => c.clientId == clientId);
  }

  // ===== Data Initialization =====
  /// Initialize with dummy data (for development)
  void initializeDummyData() {
    _clients.clear();
    _clients.addAll(_generateDummyClients());
  }

  /// Generate dummy clients for testing
  List<Client> _generateDummyClients() {
    final now = DateTime.now();
    
    return [
      Client(
        clientId: '1',
        name: 'AnnaDummy',
        age: 25,
        gender: 'Female',
        active: 0,
        motivation: 'Motivated',
        exercises: [
          CountableExercise(
            exerciseId: '1_1',
            name: 'Push-ups',
            description: 'Standard push-ups',
            sets: 3,
            reps: 12,
          ),
          TimeableExercise(
            exerciseId: '1_2',
            name: 'Running',
            description: 'Treadmill running',
            time: 30,
          ),
        ],
        appointments: [
          Appointment(
            timestamp: (now.add(const Duration(hours: 1)).millisecondsSinceEpoch ~/ 1000),
          ),
          Appointment(
            timestamp: (now.add(const Duration(days: 3)).millisecondsSinceEpoch ~/ 1000),
          ),
        ],
      ),
      Client(
        clientId: '2',
        name: 'MarkDummy',
        age: 30,
        gender: 'Male',
        active: 1,
        motivation: 'Needs support',
        exercises: [],
        appointments: [
          Appointment(
            timestamp: (now.add(const Duration(days: 2)).millisecondsSinceEpoch ~/ 1000),
          ),
        ],
      ),
      Client(
        clientId: '3',
        name: 'SophiaDummy',
        age: 28,
        gender: 'Female',
        active: 2,
        motivation: 'Struggling',
        exercises: [],
        appointments: [
          Appointment(
            timestamp: (now.add(const Duration(days: 5)).millisecondsSinceEpoch ~/ 1000),
          ),
          Appointment(
            timestamp: (now.add(const Duration(days: 7)).millisecondsSinceEpoch ~/ 1000),
          ),
        ],
      ),
    ];
  }

  // ===== Search & Filter =====
  /// Search clients by name
  List<Client> searchClients(String query) {
    if (query.isEmpty) return getClients();
    return _clients
        .where((c) => c.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  /// Get clients with appointments on a given day
  List<Client> getClientsForDay(DateTime day) {
    return _clients.where((client) {
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

  // ===== Utility =====
  /// Clear all data
  void clear() => _clients.clear();

  /// Get client count
  int getClientCount() => _clients.length;
}
