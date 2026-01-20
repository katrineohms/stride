// Files
import '../../model/clients.dart';

/// ViewModel for managing exercise form state and logic
class ExerciseFormViewModel {
  final List<Exercise> _exercises = [];

  // ===== Form State =====
  String name = '';
  String description = '';
  int sets = 0;
  int reps = 0;
  int time = 0; // in seconds
  bool isCountable = true; // true = sets/reps, false = time-based

  // ===== Getters =====
  List<Exercise> get exercises => List.from(_exercises);

  // ===== Initialization =====
  void initialize(List<Exercise> initialExercises) {
    _exercises.clear();
    _exercises.addAll(initialExercises);
  }

  // ===== Form Field Updates =====
  void updateName(String newName) => name = newName.trim();
  void updateDescription(String newDescription) =>
      description = newDescription.trim();
  void updateSets(String value) => sets = int.tryParse(value) ?? 0;
  void updateReps(String value) => reps = int.tryParse(value) ?? 0;
  void updateTime(String value) => time = int.tryParse(value) ?? 0;

  /// Toggle between countable and time-based exercises
  void toggleExerciseType() {
    isCountable = !isCountable;
    clearRelevantFields();
  }

  /// Clear fields that aren't relevant for the current exercise type
  void clearRelevantFields() {
    if (isCountable) {
      time = 0;
    } else {
      sets = 0;
      reps = 0;
    }
  }

  // ===== Reset Form =====
  void resetForm() {
    name = '';
    description = '';
    sets = 0;
    reps = 0;
    time = 0;
    isCountable = true;
  }

  // ===== CRUD Operations =====
  /// Create a new exercise from current form state
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

  /// Add exercise to list
  void addExercise(Exercise exercise) {
    _exercises.add(exercise);
  }

  /// Update an existing exercise in the list
  void updateExercise(int index, Exercise updatedExercise) {
    if (index >= 0 && index < _exercises.length) {
      _exercises[index] = updatedExercise;
    }
  }

  /// Remove an exercise from the list
  void removeExercise(Exercise exercise) {
    _exercises.remove(exercise);
  }

  // ===== Populate Form from Exercise =====
  /// Pre-fill form fields from an existing exercise
  void populateFormFromExercise(Exercise exercise) {
    name = exercise.name;
    description = exercise.description;

    if (exercise is CountableExercise) {
      isCountable = true;
      sets = exercise.sets;
      reps = exercise.reps;
      time = 0;
    } else if (exercise is TimeableExercise) {
      isCountable = false;
      time = exercise.time;
      sets = 0;
      reps = 0;
    }
  }

  // ===== Validation =====
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
}
