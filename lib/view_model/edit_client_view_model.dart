// Files
import 'package:flutter/material.dart';
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

  // ======= Form Data =======
  // Controllers for personal info
  late String name = client.name;
  late int age = client.age;
  late String gender = client.gender;
  late String motivation = client.motivation;
  late int active = client.active;

  // Sessions & exercise templates
  List<Session> sessions = [];
  List<Exercise> exerciseTemplates = [];

  // ======= Constants =======
  /// Available gender options for dropdown
  static const List<String> genderOptions = ['Male', 'Female', 'Other'];

  /// Status options with their integer values and display labels
  static const Map<int, String> statusOptions = {
    0: 'Active',
    1: 'Caution',
    2: 'Inactive',
  };

  /// Get color for status indicator
  static Color getStatusColor(int status) {
    switch (status) {
      case 0:
        return Colors.green;
      case 1:
        return Colors.yellow;
      case 2:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // ======= Lifecycle =======
  // Initialize lists
  void init() {
    sessions = List.from(client.sessions);
    exerciseTemplates = List.from(client.exerciseTemplates);
  }

  // ===== Personal Info Updates =====
  void updateName(String newName) => name = newName;
  void updateAge(int newAge) => age = newAge;
  void updateGender(String newGender) => gender = newGender;
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
      gender: gender,
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
