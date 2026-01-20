// Files
import '../model/_models.dart';
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

  // Sessions & exercise templates
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
    return client.copyWith(
      name: name,
      age: age,
      motivation: motivation,
      active: active,
      sessions: sessions,
      exerciseTemplates: exerciseTemplates,
    );
  }

  // ===== Sessions =====
  void addSession(Session session) => sessions.add(session);
  void removeSession(Session session) => sessions.remove(session);
}
