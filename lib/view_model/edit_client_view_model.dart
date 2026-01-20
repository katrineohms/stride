// Files
import 'package:uuid/uuid.dart';
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

  // Appointments & exercise templates
  List<Appointment> appointments = [];
  List<Exercise> exerciseTemplates = [];

  // Initialize lists
  void init() {
    appointments = client.sessions
      .map((s) => Appointment(timestamp: s.startTime, notes: s.notes ?? ''))
      .toList();
    exerciseTemplates = List.from(client.exerciseTemplates);
  }

  // ===== Personal Info Updates =====
  void updateName(String newName) => name = newName;
  void updateAge(int newAge) => age = newAge;
  void updateMotivation(String newMotivation) =>
      motivation = newMotivation;
  void updateActive(int newActive) => active = newActive;

  // ===== Appointments =====
  void addAppointment(Appointment a) => appointments.add(a);
  void removeAppointment(Appointment a) => appointments.remove(a);

  // ===== Exercises =====
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
    final sessions = appointments
        .map((a) => Session(
              sessionId: const Uuid().v4(),
              startTime: a.timestamp,
              hrReadings: const [],
              startLocationCity: null,
              notes: a.notes,
            ))
        .toList();

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
