import 'package:flutter/material.dart';
import '../model/clients.dart';
import '../view_model/create_client_view_model.dart';

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
  final CreateExerciseViewModel viewModel = CreateExerciseViewModel();

  late List<Exercise> _exercises;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _setsController = TextEditingController();
  final TextEditingController _repsController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _exercises = List.from(widget.initialExercises);
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

  void _clearRelevantFieldsOnToggle() {
    if (viewModel.isCountable) {
      _timeController.clear();
      viewModel.time = 0;
    } else {
      _setsController.clear();
      _repsController.clear();
      viewModel.sets = 0;
      viewModel.reps = 0;
    }
  }

  void _addExercise() {
    viewModel.name = _nameController.text.trim();
    viewModel.description = _descriptionController.text.trim();
    viewModel.sets = int.tryParse(_setsController.text) ?? 0;
    viewModel.reps = int.tryParse(_repsController.text) ?? 0;
    viewModel.time = int.tryParse(_timeController.text) ?? 0;

    if (_formKey.currentState!.validate()) {
      final exercise = viewModel.createExercise();

      setState(() {
        _exercises.add(exercise);
        _nameController.clear();
        _descriptionController.clear();
        _setsController.clear();
        _repsController.clear();
        _timeController.clear();
      });

      widget.onCreate(exercise);
    }
  }

  Future<void> _editExercise(Exercise ex) async {
    // Pre-fill controllers with existing values
    _nameController.text = ex.name;
    _descriptionController.text = ex.description;
    if (ex is CountableExercise) {
      viewModel.isCountable = true;
      _setsController.text = ex.sets.toString();
      _repsController.text = ex.reps.toString();
    } else if (ex is TimeableExercise) {
      viewModel.isCountable = false;
      _timeController.text = ex.time.toString();
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
      // Update exercise
      viewModel.name = _nameController.text.trim();
      viewModel.description = _descriptionController.text.trim();
      viewModel.sets = int.tryParse(_setsController.text) ?? 0;
      viewModel.reps = int.tryParse(_repsController.text) ?? 0;
      viewModel.time = int.tryParse(_timeController.text) ?? 0;

      final updatedExercise = viewModel.createExercise();

      setState(() {
        final index = _exercises.indexOf(ex);
        if (index != -1) _exercises[index] = updatedExercise;
      });

      widget.onUpdate?.call(updatedExercise);
    } else if (result == 'delete') {
      _removeExercise(ex);
    }

    // Clear controllers after dialog closes
    _nameController.clear();
    _descriptionController.clear();
    _setsController.clear();
    _repsController.clear();
    _timeController.clear();
  }

  void _removeExercise(Exercise ex) {
    setState(() {
      _exercises.remove(ex);
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
                          viewModel.isCountable = val;
                          _clearRelevantFieldsOnToggle();
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
            if (_exercises.isNotEmpty)
              Column(
                children: _exercises
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
