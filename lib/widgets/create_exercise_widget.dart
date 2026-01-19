import 'package:flutter/material.dart';
import '../model/clients.dart';
import '../view_model/widgets_view_model/exercise_form_view_model.dart';

// ============= SMART WIDGET (Container) =============
/// Manages exercise form logic, state, and form controllers
class ExerciseFormWidget extends StatefulWidget {
  final ExerciseFormViewModel viewModel;
  final List<Exercise> initialExercises;
  final Function(Exercise) onCreate;
  final Function(Exercise)? onUpdate;
  final Function(Exercise)? onRemove;

  const ExerciseFormWidget({
    super.key,
    required this.viewModel,
    this.initialExercises = const [],
    required this.onCreate,
    this.onUpdate,
    this.onRemove,
  });

  @override
  State<ExerciseFormWidget> createState() => _ExerciseFormWidgetState();
}

class _ExerciseFormWidgetState extends State<ExerciseFormWidget> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _setsController = TextEditingController();
  final TextEditingController _repsController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.viewModel.initialize(widget.initialExercises);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _setsController.dispose();
    _repsController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  void _syncFormToViewModel() {
    widget.viewModel.updateName(_nameController.text);
    widget.viewModel.updateDescription(_descriptionController.text);
    widget.viewModel.updateSets(_setsController.text);
    widget.viewModel.updateReps(_repsController.text);
    widget.viewModel.updateTime(_timeController.text);
  }

  void _clearFormControllers() {
    _nameController.clear();
    _descriptionController.clear();
    _setsController.clear();
    _repsController.clear();
    _timeController.clear();
  }

  void _addExercise() {
    _syncFormToViewModel();

    if (_formKey.currentState!.validate()) {
      final exercise = widget.viewModel.createExercise();

      setState(() {
        widget.viewModel.addExercise(exercise);
        _clearFormControllers();
        widget.viewModel.resetForm();
      });

      widget.onCreate(exercise);
    }
  }

  Future<void> _editExercise(Exercise ex) async {
    widget.viewModel.populateFormFromExercise(ex);
    _nameController.text = widget.viewModel.name;
    _descriptionController.text = widget.viewModel.description;
    if (widget.viewModel.isCountable) {
      _setsController.text = widget.viewModel.sets.toString();
      _repsController.text = widget.viewModel.reps.toString();
    } else {
      _timeController.text = widget.viewModel.time.toString();
    }

    final result = await showDialog<String>(
      context: context,
      builder: (_) => _ExerciseEditDialog(
        name: _nameController.text,
        description: _descriptionController.text,
        isCountable: widget.viewModel.isCountable,
        sets: _setsController.text,
        reps: _repsController.text,
        time: _timeController.text,
        onNameChanged: (v) => _nameController.text = v,
        onDescriptionChanged: (v) => _descriptionController.text = v,
        onSetsChanged: (v) => _setsController.text = v,
        onRepsChanged: (v) => _repsController.text = v,
        onTimeChanged: (v) => _timeController.text = v,
      ),
    );

    if (result == 'save') {
      _syncFormToViewModel();
      final updatedExercise = widget.viewModel.createExercise();

      setState(() {
        final index = widget.viewModel.exercises.indexOf(ex);
        if (index != -1) {
          widget.viewModel.updateExercise(index, updatedExercise);
        }
      });

      widget.onUpdate?.call(updatedExercise);
    } else if (result == 'delete') {
      _removeExercise(ex);
    }

    _clearFormControllers();
    widget.viewModel.resetForm();
  }

  void _removeExercise(Exercise ex) {
    setState(() {
      widget.viewModel.removeExercise(ex);
    });
    widget.onRemove?.call(ex);
  }

  @override
  Widget build(BuildContext context) {
    // Pass state and callbacks to dumb view widget
    return _ExerciseFormView(
      formKey: _formKey,
      exercises: widget.viewModel.exercises,
      isCountable: widget.viewModel.isCountable,
      nameController: _nameController,
      descriptionController: _descriptionController,
      setsController: _setsController,
      repsController: _repsController,
      timeController: _timeController,
      viewModel: widget.viewModel,
      onAddExercise: _addExercise,
      onEditExercise: _editExercise,
      onRemoveExercise: _removeExercise,
      onToggleExerciseType: () {
        setState(() {
          widget.viewModel.toggleExerciseType();
        });
      },
    );
  }
}

// ============= DUMB WIDGET (Presentational) =============
/// Pure UI widget for rendering the exercise form
class _ExerciseFormView extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final List<Exercise> exercises;
  final bool isCountable;
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final TextEditingController setsController;
  final TextEditingController repsController;
  final TextEditingController timeController;
  final ExerciseFormViewModel viewModel;
  final VoidCallback onAddExercise;
  final Function(Exercise) onEditExercise;
  final Function(Exercise) onRemoveExercise;
  final VoidCallback onToggleExerciseType;

  const _ExerciseFormView({
    required this.formKey,
    required this.exercises,
    required this.isCountable,
    required this.nameController,
    required this.descriptionController,
    required this.setsController,
    required this.repsController,
    required this.timeController,
    required this.viewModel,
    required this.onAddExercise,
    required this.onEditExercise,
    required this.onRemoveExercise,
    required this.onToggleExerciseType,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title + toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Exercises',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    const Text('Timed'),
                    Switch(
                      value: isCountable,
                      onChanged: (_) => onToggleExerciseType(),
                    ),
                    const Text('Countable'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Existing exercises
            if (exercises.isNotEmpty)
              Column(
                children: exercises
                    .map((ex) => Card(
                          color: Colors.grey[100],
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            leading: const Icon(Icons.fitness_center,
                                color: Colors.green),
                            title: Text(ex.name),
                            subtitle: Text(
                              ex is CountableExercise
                                  ? 'Sets: ${ex.sets}, Reps: ${ex.reps}'
                                  : 'Time: ${(ex as TimeableExercise).time}s',
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => onEditExercise(ex),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            const SizedBox(height: 8),

            // Form for adding new exercise
            Form(
              key: formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Exercise Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v?.trim().isEmpty ?? true
                        ? 'Enter exercise name'
                        : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    minLines: 2,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 8),
                  if (isCountable) ...[
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: setsController,
                            decoration:
                                const InputDecoration(labelText: 'Sets', border: OutlineInputBorder()),
                            keyboardType: TextInputType.number,
                            validator: (_) => viewModel.validateSets(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: repsController,
                            decoration:
                                const InputDecoration(labelText: 'Reps', border: OutlineInputBorder()),
                            keyboardType: TextInputType.number,
                            validator: (_) => viewModel.validateReps(),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    TextFormField(
                      controller: timeController,
                      decoration: const InputDecoration(
                        labelText: 'Time (seconds)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (_) => viewModel.validateTime(),
                    ),
                  ],
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onAddExercise,
                      child: const Text('Add Exercise'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============= DUMB DIALOG WIDGET (Presentational) =============
/// Pure UI widget for the exercise edit dialog
class _ExerciseEditDialog extends StatelessWidget {
  final String name;
  final String description;
  final bool isCountable;
  final String sets;
  final String reps;
  final String time;
  final Function(String) onNameChanged;
  final Function(String) onDescriptionChanged;
  final Function(String) onSetsChanged;
  final Function(String) onRepsChanged;
  final Function(String) onTimeChanged;

  const _ExerciseEditDialog({
    required this.name,
    required this.description,
    required this.isCountable,
    required this.sets,
    required this.reps,
    required this.time,
    required this.onNameChanged,
    required this.onDescriptionChanged,
    required this.onSetsChanged,
    required this.onRepsChanged,
    required this.onTimeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Exercise'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextFormField(
              initialValue: name,
              decoration: const InputDecoration(labelText: 'Name'),
              onChanged: onNameChanged,
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: description,
              decoration: const InputDecoration(labelText: 'Description'),
              minLines: 2,
              maxLines: 4,
              onChanged: onDescriptionChanged,
            ),
            const SizedBox(height: 8),
            if (isCountable) ...[
              TextFormField(
                initialValue: sets,
                decoration: const InputDecoration(labelText: 'Sets'),
                keyboardType: TextInputType.number,
                onChanged: onSetsChanged,
              ),
              const SizedBox(height: 4),
              TextFormField(
                initialValue: reps,
                decoration: const InputDecoration(labelText: 'Reps'),
                keyboardType: TextInputType.number,
                onChanged: onRepsChanged,
              ),
            ] else ...[
              TextFormField(
                initialValue: time,
                decoration: const InputDecoration(labelText: 'Time (s)'),
                keyboardType: TextInputType.number,
                onChanged: onTimeChanged,
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, 'delete'),
          child: const Text('Delete', style: TextStyle(color: Colors.red)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, 'save'),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
