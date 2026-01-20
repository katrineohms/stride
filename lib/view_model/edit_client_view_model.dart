// Files
import '../model/clients.dart';
import '../view_model/movesense_connect_view_model.dart';

// Services
import '../service/movesense_service.dart';

class EditClientViewModel {
  late Client client;
  final MovesenseConnectViewModel movesense;

  EditClientViewModel({
    required this.client,
    MovesenseConnectViewModel? movesense,
  }) : movesense = movesense ?? MovesenseService().viewModel;

  // Controllers for personal info
  late String name = client.name;
  late int age = client.age;
  late String motivation = client.motivation;
  late int active = client.active;

  // Appointments & exercises
  List<Session> sessions = [];
  List<Exercise> exerciseTemplates = [];

  // Initialize lists
  void init() {
    sessions = List.from(client.sessions);
    exerciseTemplates = List.from(client.exerciseTemplates);
  }

  // ===== Personal Info Updates =====
  void updateName(String newName) => name = newName;
  void updateAge(int newAge) => age = newAge;
  void updateMotivation(String newMotivation) =>
      motivation = newMotivation;
  void updateActive(int newActive) => active = newActive;

  // ===== Appointments (via Sessions) =====
  void addAppointment(Appointment a) {
    // Create a new session with this appointment
    final session = Session(
      sessionId: '${client.clientId}_${DateTime.now().millisecondsSinceEpoch}',
      appointment: a,
      startTime: a.timestamp,
      hrReadings: const [],
    );
    sessions.add(session);
  }

  void removeAppointment(Appointment a) {
    sessions.removeWhere((s) => 
      s.appointment.timestamp == a.timestamp && 
      s.appointment.notes == a.notes
    );
  }

  /// Get list of appointments for the appointment widget
  List<Appointment> get appointments => 
      sessions.map((s) => s.appointment).toList();

  // ===== Exercise Templates =====
  void addExercise(Exercise ex) => exerciseTemplates.add(ex);
  void removeExercise(Exercise ex) => exerciseTemplates.remove(ex);

  void updateExercise(int index, Exercise updated) {
    if (index >= 0 && index < exerciseTemplates.length) {
      exerciseTemplates[index] = updated;
    }
  }

  // ===== Validation =====
  String? validateName() => name.isEmpty ? 'Enter a name' : null;
  String? validateAge() => age <= 0 ? 'Enter a valid age' : null;

  bool validateAll() =>
      validateName() == null &&
      validateAge() == null;

  // ===== Build final Client object =====
  Client buildClient() {
    return client.copyWith(
      name: name,
      age: age,
      motivation: motivation,
      active: active,
      sessions: sessions,
      exerciseTemplates: exerciseTemplates,
    );
  }
}
