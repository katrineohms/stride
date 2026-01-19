import 'package:flutter/material.dart';
import '../model/clients.dart';
import '../view_model/exercise_form_view_model.dart';

class ExerciseFormWidget extends StatefulWidget {
  final List<Exercise> initialExercises;
  final Function(Exercise) onCreate;
  final Function(Exercise)? onUpdate;
  final Function(Exercise)? onRemove;

  const ExerciseFormWidget({
    super.key,
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
  late ExerciseFormViewModel viewModel;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _setsController = TextEditingController();
  final TextEditingController _repsController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    viewModel = ExerciseFormViewModel();
    viewModel.initialize(widget.initialExercises);
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
    viewModel.updateName(_nameController.text);
    viewModel.updateDescription(_descriptionController.text);
    viewModel.updateSets(_setsController.text);
    viewModel.updateReps(_repsController.text);
    viewModel.updateTime(_timeController.text);
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
      final exercise = viewModel.createExercise();

      setState(() {
        viewModel.addExercise(exercise);
        _clearFormControllers();
        viewModel.resetForm();
      });

      widget.onCreate(exercise);
    }
  }

  Future<void> _editExercise(Exercise ex) async {
    viewModel.populateFormFromExercise(ex);
    _nameController.text = viewModel.name;
    _descriptionController.text = viewModel.description;
    if (viewModel.isCountable) {
      _setsController.text = viewModel.sets.toString();
      _repsController.text = viewModel.reps.toString();
    } else {
      _timeController.text = viewModel.time.toString();
    }

    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Exercise'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                minLines: 2,
                maxLines: 4,
              ),
              const SizedBox(height: 8),
              if (viewModel.isCountable) ...[
                TextFormField(
                  controller: _setsController,
                  decoration: const InputDecoration(labelText: 'Sets'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 4),
                TextFormField(
                  controller: _repsController,
                  decoration: const InputDecoration(labelText: 'Reps'),
                  keyboardType: TextInputType.number,
                ),
              ] else ...[
                TextFormField(
                  controller: _timeController,
                  decoration: const InputDecoration(labelText: 'Time (s)'),
                  keyboardType: TextInputType.number,
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
      ),
    );

    if (result == 'save') {
      _syncFormToViewModel();
      final updatedExercise = viewModel.createExercise();

      setState(() {
        final index = viewModel.exercises.indexOf(ex);
        if (index != -1) {
          viewModel.updateExercise(index, updatedExercise);
        }
      });

      widget.onUpdate?.call(updatedExercise);
    } else if (result == 'delete') {
      _removeExercise(ex);
    }

    _clearFormControllers();
    viewModel.resetForm();
  }

  void _removeExercise(Exercise ex) {
    setState(() {
      viewModel.removeExercise(ex);
    });
    widget.onRemove?.call(ex);
  }

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
                      value: viewModel.isCountable,
                      onChanged: (val) {
                        setState(() {
                          viewModel.toggleExerciseType();
                        });
                      },
                    ),
                    const Text('Countable'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Existing exercises
            if (viewModel.exercises.isNotEmpty)
              Column(
                children: viewModel.exercises
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
                              onPressed: () => _editExercise(ex),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            const SizedBox(height: 8),

            // Form for adding new exercise
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
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
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    minLines: 2,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 8),
                  if (viewModel.isCountable) ...[
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _setsController,
                            decoration:
                                const InputDecoration(labelText: 'Sets', border: OutlineInputBorder()),
                            keyboardType: TextInputType.number,
                            validator: (_) => viewModel.validateSets(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _repsController,
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
                      controller: _timeController,
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
                      onPressed: _addExercise,
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
