import '../model/clients.dart';

class EditClientViewModel {
  late Client client;

  EditClientViewModel({required this.client});

  // Controllers for personal info
  late String name = client.name;
  late int age = client.age;
  late String motivation = client.motivation;
  late int active = client.active;

  // Appointments & exercises
  List<Appointment> appointments = [];
  List<Exercise> exercises = [];

  // Initialize lists
  void init() {
    appointments = List.from(client.appointments);
    exercises = List.from(client.exercises);
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
  void addExercise(Exercise ex) => exercises.add(ex);
  void removeExercise(Exercise ex) => exercises.remove(ex);

  void updateExercise(int index, Exercise updated) {
    if (index >= 0 && index < exercises.length) {
      exercises[index] = updated;
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
      appointments: appointments,
      exercises: exercises,
    );
  }
}
