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

  // List of exercises added so far
  final List<Exercise> _addedExercises = [];

  // Controllers for form fields
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

  void _addExercise() {
    if (_formKey.currentState!.validate()) {
      // Sync controllers to viewModel
      viewModel.name = _nameController.text;
      viewModel.description = _descriptionController.text;
      viewModel.sets = int.tryParse(_setsController.text) ?? 0;
      viewModel.reps = int.tryParse(_repsController.text) ?? 0;
      viewModel.time = int.tryParse(_timeController.text) ?? 0;

      final exercise = viewModel.createExercise();

      setState(() {
        _addedExercises.add(exercise);
        _nameController.clear();
        _descriptionController.clear();
        _setsController.clear();
        _repsController.clear();
        _timeController.clear();
      });

      // Notify parent (e.g., CreateClientPage) about new exercise
      widget.onCreate(exercise);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Show added exercises as cards
        ..._addedExercises.map((ex) => Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                title: Text(ex.name),
                subtitle: Text(
                    'Sets: ${ex.sets}, Reps: ${ex.reps}, Time: ${ex.time}s'),
              ),
            )),

        const SizedBox(height: 8),

        // Form to add a new exercise
        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Exercise Name'),
                validator: (v) => v?.isEmpty ?? true ? 'Enter exercise name' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextFormField(
                controller: _setsController,
                decoration: const InputDecoration(labelText: 'Sets'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _repsController,
                decoration: const InputDecoration(labelText: 'Reps'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _timeController,
                decoration: const InputDecoration(labelText: 'Time (seconds)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _addExercise,
                child: const Text('Add Exercise'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
