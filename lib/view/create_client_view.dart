// Packages
import 'package:flutter/material.dart';

// Files
import '../model/clients.dart';
import '../view_model/create_client_view_model.dart';
import '../view_model/widgets_view_model/appointment_form_view_model.dart';
import '../view_model/widgets_view_model/exercise_form_view_model.dart';

// Widgets
import '../widgets/movesense_status_widget.dart';
import '../widgets/create_exercise_widget.dart';
import '../widgets/appointments_widget.dart';

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
  
  // ======= Form ViewModels =======
  late final AppointmentFormViewModel appointmentFormViewModel;
  late final ExerciseFormViewModel exerciseFormViewModel;

  // ======= Controllers =======
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _motivationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize form ViewModels
    appointmentFormViewModel = AppointmentFormViewModel();
    exerciseFormViewModel = ExerciseFormViewModel();
  }

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
      appBar: AppBar(
        title: const Text('Create Client'),
        actions: [
          ListenableBuilder(
            listenable: viewModel.movesense,
            builder: (context, _) {
              return MovesenseStatusIcon(
                connected: viewModel.movesense.isConnected,
                heartRate: 0,
                heartRateStream: viewModel.movesense.heartRateStream,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Card(
                color: Theme.of(context).cardColor,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.symmetric(vertical: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Personal Info',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Name + Age
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Name',
                                border: OutlineInputBorder(),
                              ),
                              validator: (_) {
                                _updateViewModel();
                                return viewModel.validateName();
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _ageController,
                              decoration: const InputDecoration(
                                labelText: 'Age',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (_) {
                                _updateViewModel();
                                return viewModel.validateAge();
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Gender + Status
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              initialValue: viewModel.active,
                              decoration: const InputDecoration(
                                labelText: 'Status',
                                border: OutlineInputBorder(),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 0,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.circle,
                                        color: Colors.green,
                                        size: 14,
                                      ),
                                      SizedBox(width: 6),
                                      Text('Active'),
                                    ],
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 1,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.circle,
                                        color: Colors.yellow,
                                        size: 14,
                                      ),
                                      SizedBox(width: 6),
                                      Text('Caution'),
                                    ],
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 2,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.circle,
                                        color: Colors.red,
                                        size: 14,
                                      ),
                                      SizedBox(width: 6),
                                      Text('Inactive'),
                                    ],
                                  ),
                                ),
                              ],
                              onChanged: (v) {
                                if (v != null) {
                                  setState(() => viewModel.active = v);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Motivation
                      TextFormField(
                        controller: _motivationController,
                        decoration: const InputDecoration(
                          labelText: 'Motivation',
                          hintText: 'Optional motivation notes',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),

              // ======= Appointments =======
              AppointmentFormWidget(
                viewModel: appointmentFormViewModel,
                onCreate: (appointment) {
                  setState(() {
                    viewModel.appointments.add(appointment);
                  });
                },
              ),

              const SizedBox(height: 12),

              // Exercise form
              ExerciseFormWidget(
                viewModel: exerciseFormViewModel,
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
                  if (_formKey.currentState!.validate() &&
                      viewModel.validateAll()) {
                    final client = viewModel.createClient();
                    widget.onCreate(client);
                    Navigator.pop(context);
                  } else {
                    // Show error snackbar
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please fix the errors in the form'),
                      ),
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
