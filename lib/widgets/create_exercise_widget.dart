import 'package:flutter/material.dart';
import '../model/clients.dart';
import '../view_model/create_client_view_model.dart';

class ExerciseFormWidget extends StatefulWidget {
  final Function(Exercise) onCreate;

  const ExerciseFormWidget({super.key, required this.onCreate});

  @override
  State<ExerciseFormWidget> createState() => _ExerciseFormWidgetState();
}

class _ExerciseFormWidgetState extends State<ExerciseFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final CreateExerciseViewModel viewModel = CreateExerciseViewModel();

  final List<Exercise> _addedExercises = [];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _setsController = TextEditingController();
  final TextEditingController _repsController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

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
    // When toggling type, clear the irrelevant fields so validation won't trip
    if (viewModel.isCountable) {
      // switched to countable -> clear time
      _timeController.clear();
      viewModel.time = 0;
    } else {
      // switched to time-based -> clear sets/reps
      _setsController.clear();
      _repsController.clear();
      viewModel.sets = 0;
      viewModel.reps = 0;
    }
  }

  void _addExercise() {
    // sync current text fields into the viewModel before validating
    viewModel.name = _nameController.text.trim();
    viewModel.description = _descriptionController.text.trim();
    viewModel.sets = int.tryParse(_setsController.text) ?? 0;
    viewModel.reps = int.tryParse(_repsController.text) ?? 0;
    viewModel.time = int.tryParse(_timeController.text) ?? 0;

    if (_formKey.currentState!.validate()) {
      final exercise = viewModel.createExercise();

      setState(() {
        _addedExercises.add(exercise);
        // clear form fields for next entry
        _nameController.clear();
        _descriptionController.clear();
        _setsController.clear();
        _repsController.clear();
        _timeController.clear();
      });

      // notify parent (e.g., CreateClientPage) so it can also keep the exercise list
      widget.onCreate(exercise);
    }
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
                // simple switch to choose type
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

            // Existing added exercises
            if (_addedExercises.isNotEmpty) ...[
              Column(
                children: _addedExercises
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
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 8),
            ],

            // Form
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // name
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Exercise Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v?.trim().isEmpty ?? true ? 'Enter exercise name' : null,
                  ),
                  const SizedBox(height: 8),

                  // description - bigger multiline box
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

                  // conditional fields
                  if (viewModel.isCountable) ...[
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _setsController,
                            decoration: const InputDecoration(
                              labelText: 'Sets',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (_) =>
                                viewModel.validateSets(), // only validates when countable
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _repsController,
                            decoration: const InputDecoration(
                              labelText: 'Reps',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (_) => viewModel.validateReps(),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    // time-based
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

                  // full width add button
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
