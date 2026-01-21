// Packages
import 'package:flutter/material.dart';

// Files
import '../model/_models.dart';
import '../view_model/create_client_view_model.dart';
import '../view_model/widgets_view_model/exercise_form_view_model.dart';
import '../view_model/widgets_view_model/session_schedule_view_model.dart';

// Widgets
import '../widgets/movesense_status_widget.dart';
import '../widgets/create_exercise_widget.dart';
import '../widgets/session_schedule_widget.dart';

/// ============================================
/// CREATE CLIENT PAGE
/// ============================================
/// Form-based page for creating a new client with:
/// - Personal information (name, age, gender, status)
/// - Motivation notes
/// - Exercise templates
/// - Scheduled sessions
/// - Form validation before submission

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
  late final ExerciseFormViewModel exerciseFormViewModel;
  late final SessionScheduleViewModel sessionScheduleViewModel;

  // ======= Controllers =======
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _motivationController = TextEditingController();

  // ======= Lifecycle Methods =======
  @override
  void initState() {
    super.initState();
    // Initialize form ViewModels
    exerciseFormViewModel = ExerciseFormViewModel();
    sessionScheduleViewModel = SessionScheduleViewModel();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _motivationController.dispose();
    super.dispose();
  }

  // ======= Form Synchronization =======
  /// Sync form fields with view model for validation
  void _updateViewModel() {
    viewModel.name = _nameController.text;
    viewModel.age = int.tryParse(_ageController.text);
    viewModel.motivation = _motivationController.text;
  }

  // ======= Build UI =======
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ======= App Bar =======
      appBar: AppBar(
        title: const Text('Create Client'),
        actions: [
          MovesenseAppBarStatus(viewModel: viewModel.movesense),
        ],
      ),
      // ======= Body: Form =======
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ======= Personal Information Card =======
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

                      // ======= Name & Age Fields =======
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

                      // ======= Gender & Status Dropdowns =======
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: viewModel.gender,
                              decoration: const InputDecoration(
                                labelText: 'Gender',
                                border: OutlineInputBorder(),
                              ),
                              items: CreateClientViewModel.genderOptions
                                  .map((gender) => DropdownMenuItem(
                                        value: gender,
                                        child: Text(gender),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => viewModel.gender = value);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              initialValue: viewModel.active,
                              decoration: const InputDecoration(
                                labelText: 'Status',
                                border: OutlineInputBorder(),
                              ),
                              items: CreateClientViewModel.statusOptions.entries
                                  .map((entry) => DropdownMenuItem(
                                        value: entry.key,
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.circle,
                                              color: CreateClientViewModel.getStatusColor(entry.key),
                                              size: 14,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(entry.value),
                                          ],
                                        ),
                                      ))
                                  .toList(),
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

                      // ======= Motivation Field =======
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

              // ======= Scheduled Sessions =======
              SessionScheduleWidget(
                viewModel: sessionScheduleViewModel,
                initialSessions: viewModel.scheduledSessions,
                onCreate: (session) {
                  setState(() {
                    viewModel.addScheduledSession(session);
                  });
                },
                onRemove: (session) {
                  setState(() {
                    viewModel.removeScheduledSession(session);
                  });
                },
              ),

              const SizedBox(height: 12),

              // ======= Exercise Templates =======
              ExerciseFormWidget(
                viewModel: exerciseFormViewModel,
                onCreate: (exercise) {
                  setState(() {
                    // Add the exercise to the client in the view model
                    viewModel.exerciseTemplates.add(exercise);
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
