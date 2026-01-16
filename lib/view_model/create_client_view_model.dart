import '../model/clients.dart';

class CreateClientViewModel {
  String name = '';
  int? age;
  String gender = 'Male';
  int active = 0; // 0 = green, 1 = yellow, 2 = red
  DateTime? nextAppointment;
  String motivation = '';

  // Define a list to hold exercises
  List<Exercise> exercises = []; // Ensure Exercise is the correct type

  String? validateName() {
    if (name.isEmpty) return 'Enter a name';
    return null;
  }

  String? validateAge() {
    if (age == null || age! <= 0) return 'Enter a valid age';
    return null;
  }

  String? validateNextAppointment() {
    if (nextAppointment == null) return 'Pick a next appointment';
    return null;
  }

  bool validateAll() {
    return validateName() == null &&
        validateAge() == null &&
        validateNextAppointment() == null;
  }

  Client createClient() {
    if (!validateAll()) {
      throw Exception('Cannot create client: invalid data');
    }

    return Client(
      clientId: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      age: age!,
      gender: gender,
      active: active,
      nextAppointment: nextAppointment!.millisecondsSinceEpoch ~/ 1000,
      motivation: motivation,
      exercises: exercises
    );
  }
}
class CreateExerciseViewModel {
  String name = '';
  String description = '';
  int sets = 0;
  int reps = 0;
  int time = 0; // in seconds

  /// true = repetition-based (sets & reps)
  /// false = time-based (time)
  bool isCountable = true;

  // Validation
  String? validateName() {
    if (name.isEmpty) return 'Enter an exercise name';
    return null;
  }

  String? validateSets() {
    if (!isCountable) return null;
    if (sets <= 0) return 'Enter sets';
    return null;
  }

  String? validateReps() {
    if (!isCountable) return null;
    if (reps <= 0) return 'Enter reps';
    return null;
  }

  String? validateTime() {
    if (isCountable) return null;
    if (time <= 0) return 'Enter time in seconds';
    return null;
  }

  bool validateAll() {
    return validateName() == null &&
        validateSets() == null &&
        validateReps() == null &&
        validateTime() == null;
  }

  Exercise createExercise() {
    if (!validateAll()) {
      throw Exception('Cannot create exercise: invalid data');
    }

    final exerciseId = DateTime.now().millisecondsSinceEpoch.toString();

    if (isCountable) {
      return CountableExercise(
        exerciseId: exerciseId,
        name: name,
        description: description,
        sets: sets,
        reps: reps,
      );
    } else {
      return TimeableExercise(
        exerciseId: exerciseId,
        name: name,
        description: description,
        time: time,
      );
    }
  }
}
