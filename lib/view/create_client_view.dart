import 'package:flutter/material.dart';
import '../model/clients.dart'; // your Client class
import '../view_model/create_client_view_model.dart';
import '../widgets/create_exercise_widget.dart';

/// Page for creating a new client
class CreateClientPage extends StatefulWidget {
  final Function(Client) onCreate;

  const CreateClientPage({super.key, required this.onCreate});

  @override
  State<CreateClientPage> createState() => _CreateClientPageState();
}

class _CreateClientPageState extends State<CreateClientPage> {
  final _formKey = GlobalKey<FormState>();
  final CreateClientViewModel viewModel = CreateClientViewModel();

  // ======= Controllers =======
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _motivationController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _motivationController.dispose();
    super.dispose();
  }

  // ======= Sync form fields with view model =======
  void _updateViewModel() {
    viewModel.name = _nameController.text;
    viewModel.age = int.tryParse(_ageController.text);
    viewModel.motivation = _motivationController.text;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Client')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ======= Name =======
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (_) {
                  _updateViewModel();
                  return viewModel.validateName();
                },
              ),
              const SizedBox(height: 12),

              // ======= Age =======
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                validator: (_) {
                  _updateViewModel();
                  return viewModel.validateAge();
                },
              ),
              const SizedBox(height: 12),

              // ======= Gender =======
              DropdownButtonFormField<String>(
                initialValue: viewModel.gender,
                decoration: const InputDecoration(labelText: 'Gender'),
                items: ['Male', 'Female', 'Other']
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => viewModel.gender = v);
                },
              ),
              const SizedBox(height: 12),

              // ======= Status =======
              DropdownButtonFormField<int>(
                initialValue: viewModel.active,
                decoration: const InputDecoration(labelText: 'Status'),
                items: const [
                  DropdownMenuItem(value: 0, child: Text('Active (Green)')),
                  DropdownMenuItem(value: 1, child: Text('Caution (Yellow)')),
                  DropdownMenuItem(value: 2, child: Text('Inactive (Red)')),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => viewModel.active = v);
                },
              ),
              const SizedBox(height: 12),

              // ======= Next Appointment =======
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(viewModel.nextAppointment == null
                    ? 'Select Next Appointment'
                    : 'Next: ${viewModel.nextAppointment!.toLocal()}'
                        .split(' ')[0]),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: viewModel.nextAppointment ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) setState(() => viewModel.nextAppointment = picked);
                },
              ),
              const SizedBox(height: 12),

              // ======= Motivation =======
              TextFormField(
                controller: _motivationController,
                decoration: const InputDecoration(
                  labelText: 'Motivation',
                  hintText: 'Optional motivation notes',
                ),
                maxLines: 3,
              ),
              // Exercise form
              ExerciseFormWidget(
                onCreate: (exercise) {
                  setState(() {
                    // Add the exercise to the client in the view model
                    viewModel.exercises.add(exercise);
                  });
                },
              ),
              SizedBox(height: 4),

              // ======= Create Button =======
              ElevatedButton(
                onPressed: () {
                  _updateViewModel();
                  if (_formKey.currentState!.validate() && viewModel.validateAll()) {
                    final client = viewModel.createClient();
                    widget.onCreate(client);
                    Navigator.pop(context);
                  }
                  else {
                    // Show error snackbar
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fix the errors in the form')),
                    );
                  }
                },
                child: const Text('Create Client'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
