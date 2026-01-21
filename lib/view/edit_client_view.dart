// Packages
import 'package:flutter/material.dart';
import 'package:stride/widgets/movesense_status_widget.dart';

// Files
import '../model/_models.dart';
import '../view_model/edit_client_view_model.dart';
import '../view_model/widgets_view_model/exercise_form_view_model.dart';
import '../view_model/widgets_view_model/session_schedule_view_model.dart';

// Widgets
import '../widgets/create_exercise_widget.dart';
import '../widgets/session_schedule_widget.dart';

/// ============================================
/// EDIT CLIENT PAGE
/// ============================================
/// Form-based page for editing an existing client with:
/// - Personal information (name, age, gender, status)
/// - Motivation notes
/// - Exercise templates (add/remove)
/// - Scheduled sessions (add/remove)
/// - Form validation before saving

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
  late final ExerciseFormViewModel exerciseFormViewModel;
  late final SessionScheduleViewModel sessionScheduleViewModel;

  // ======= Controllers =======
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _motivationController;

  // ======= Lifecycle Methods =======
  @override
  void initState() {
    super.initState();

    viewModel = EditClientViewModel(client: widget.client);
    viewModel.init();
    
    // Initialize form ViewModels
    exerciseFormViewModel = ExerciseFormViewModel();
    sessionScheduleViewModel = SessionScheduleViewModel();
    sessionScheduleViewModel.initialize(viewModel.sessions);

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

  // ======= Form Synchronization =======
  /// Save text field values to ViewModel
  void _saveFieldsToViewModel() {
    viewModel.updateName(_nameController.text.trim());
    viewModel.updateAge(int.tryParse(_ageController.text) ?? viewModel.age);
    viewModel.updateMotivation(_motivationController.text.trim());
  }

  // ======= Build UI =======
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ======= App Bar =======
      appBar: AppBar(
        title: const Text('Edit Client'),
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
                      const Text('Personal Info',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
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
                              items: EditClientViewModel.genderOptions
                                  .map((gender) => DropdownMenuItem(
                                        value: gender,
                                        child: Text(gender),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => viewModel.updateGender(value));
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
                              items: EditClientViewModel.statusOptions.entries
                                  .map((entry) => DropdownMenuItem(
                                        value: entry.key,
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.circle,
                                              color: EditClientViewModel.getStatusColor(entry.key),
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
                                  setState(() => viewModel.updateActive(v));
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
                initialSessions: viewModel.incompleteScheduledSessions,
                onCreate: (session) => setState(() {
                  viewModel.addSession(session);
                }),
                onRemove: (session) => setState(() {
                  viewModel.removeSession(session);
                }),
              ),

              const SizedBox(height: 12),

              // ======= Exercise Templates =======
              ExerciseFormWidget(
                viewModel: exerciseFormViewModel,
                initialExercises: viewModel.exerciseTemplates,
                onCreate: (ex) => setState(() => viewModel.addExercise(ex)),
                onRemove: (ex) => setState(() => viewModel.removeExercise(ex)),
              ),

              const SizedBox(height: 16),

              // ======= Save Button =======
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
