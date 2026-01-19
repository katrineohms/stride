import 'package:flutter/material.dart';
import 'package:stride/widgets/movesense_status_widget.dart';
import 'package:stride/service/movesense_service.dart';
import '../model/clients.dart';
import '../widgets/appointments_widget.dart';
import '../widgets/create_exercise_widget.dart';
import '../view_model/edit_client_view_model.dart';
import '../view_model/widgets_view_model/appointment_form_view_model.dart';
import '../view_model/widgets_view_model/exercise_form_view_model.dart';

class EditClientPage extends StatefulWidget {
  final Client client;

  const EditClientPage({super.key, required this.client});

  @override
  State<EditClientPage> createState() => _EditClientPageState();
}

class _EditClientPageState extends State<EditClientPage> {
  final _formKey = GlobalKey<FormState>();
  late EditClientViewModel viewModel;
  
  // ======= Form ViewModels =======
  late final AppointmentFormViewModel appointmentFormViewModel;
  late final ExerciseFormViewModel exerciseFormViewModel;

  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _motivationController;

  @override
  void initState() {
    super.initState();

    viewModel = EditClientViewModel(client: widget.client);
    viewModel.init();
    
    // Initialize form ViewModels
    appointmentFormViewModel = AppointmentFormViewModel();
    exerciseFormViewModel = ExerciseFormViewModel();

    _nameController = TextEditingController(text: viewModel.name);
    _ageController = TextEditingController(text: viewModel.age.toString());
    _motivationController =
        TextEditingController(text: viewModel.motivation);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _motivationController.dispose();
    super.dispose();
  }

  void _saveFieldsToViewModel() {
    viewModel.updateName(_nameController.text.trim());
    viewModel.updateAge(int.tryParse(_ageController.text) ?? viewModel.age);
    viewModel.updateMotivation(_motivationController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Client'),
        actions: [
          ListenableBuilder(
            listenable: MovesenseService().viewModel,
            builder: (context, _) {
              return MovesenseStatusIcon(
                connected: MovesenseService().viewModel.isConnected,
                heartRate: 0,
                heartRateStream: MovesenseService().viewModel.heartRateStream,
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
              // ===== Personal Info =====
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
                      const Text('Personal Info',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Name',
                                border: OutlineInputBorder(),
                              ),
                              validator: (_) => viewModel.validateName(),
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
                              validator: (_) => viewModel.validateAge(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
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
                                Icon(Icons.circle, color: Colors.green, size: 14),
                                SizedBox(width: 6),
                                Text('Active'),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: 1,
                            child: Row(
                              children: [
                                Icon(Icons.circle, color: Colors.yellow, size: 14),
                                SizedBox(width: 6),
                                Text('Caution'),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: 2,
                            child: Row(
                              children: [
                                Icon(Icons.circle, color: Colors.red, size: 14),
                                SizedBox(width: 6),
                                Text('Inactive'),
                              ],
                            ),
                          ),
                        ],
                        onChanged: (v) {
                          if (v != null) {
                            setState(() => viewModel.updateActive(v));
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _motivationController,
                        decoration: const InputDecoration(
                          labelText: 'Motivation',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),

              // ===== Appointments =====
              AppointmentFormWidget(
                viewModel: appointmentFormViewModel,
                initialAppointments: viewModel.appointments,
                onCreate: (a) => setState(() => viewModel.addAppointment(a)),
                onRemove: (a) => setState(() => viewModel.removeAppointment(a)),
              ),

              const SizedBox(height: 12),

              // ===== Exercises =====
              ExerciseFormWidget(
                viewModel: exerciseFormViewModel,
                initialExercises: viewModel.exercises,
                onCreate: (ex) => setState(() => viewModel.addExercise(ex)),
                onRemove: (ex) => setState(() => viewModel.removeExercise(ex)),
              ),

              const SizedBox(height: 16),

              // ===== Save Button =====
              ElevatedButton(
                onPressed: () {
                  _saveFieldsToViewModel();
                  if (_formKey.currentState!.validate()) {
                    Navigator.pop(context, viewModel.buildClient());
                  }
                },
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
