import 'package:flutter/material.dart';
import 'package:stride/widgets/movesense_status_widget.dart';
import '../model/clients.dart';
import '../widgets/appointments_widget.dart';
import '../widgets/create_exercise_widget.dart';

class EditClientPage extends StatefulWidget {
  final Client client;

  const EditClientPage({super.key, required this.client});

  @override
  State<EditClientPage> createState() => _EditClientPageState();
}

class _EditClientPageState extends State<EditClientPage> {
  final _formKey = GlobalKey<FormState>();

  late Client editedClient;

  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _motivationController;

  @override
  void initState() {
    super.initState();

    editedClient = widget.client;

    _nameController = TextEditingController(text: editedClient.name);
    _ageController =
        TextEditingController(text: editedClient.age.toString());
    _motivationController =
        TextEditingController(text: editedClient.motivation);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _motivationController.dispose();
    super.dispose();
  }

  void _updateClientFromFields() {
    editedClient = editedClient.copyWith(
      name: _nameController.text,
      age: int.tryParse(_ageController.text) ?? editedClient.age,
      motivation: _motivationController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Client'),
        actions: const [
          MovesenseStatusIcon(connected: true, heartRate: 72),
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
                              validator: (v) =>
                                  v == null || v.isEmpty
                                      ? 'Name required'
                                      : null,
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
                              validator: (v) =>
                                  int.tryParse(v ?? '') == null
                                      ? 'Invalid age'
                                      : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Status (same as Create)
                      DropdownButtonFormField<int>(
                        initialValue: editedClient.active,
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 0,
                            child: Row(
                              children: [
                                Icon(Icons.circle,
                                    color: Colors.green, size: 14),
                                SizedBox(width: 6),
                                Text('Active'),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: 1,
                            child: Row(
                              children: [
                                Icon(Icons.circle,
                                    color: Colors.yellow, size: 14),
                                SizedBox(width: 6),
                                Text('Caution'),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: 2,
                            child: Row(
                              children: [
                                Icon(Icons.circle,
                                    color: Colors.red, size: 14),
                                SizedBox(width: 6),
                                Text('Inactive'),
                              ],
                            ),
                          ),
                        ],
                        onChanged: (v) {
                          if (v != null) {
                            setState(() {
                              editedClient =
                                  editedClient.copyWith(active: v);
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 12),

                      // Motivation
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
                initialAppointments: editedClient.appointments,
                onCreate: (appointment) {
                  setState(() {
                    editedClient = editedClient.copyWith(
                      appointments: [
                        ...editedClient.appointments,
                        appointment,
                      ],
                    );
                  });
                },
                onRemove: (appointment) {
                  setState(() {
                    editedClient = editedClient.copyWith(
                      appointments: editedClient.appointments
                          .where((a) => a != appointment)
                          .toList(),
                    );
                  });
                },
              ),

              const SizedBox(height: 12),

              // ===== Exercises =====
              ExerciseFormWidget(
                initialExercises: editedClient.exercises,
                onCreate: (exercise) {
                  setState(() {
                    editedClient = editedClient.copyWith(
                      exercises: [
                        ...editedClient.exercises,
                        exercise,
                      ],
                    );
                  });
                },
              ),

              const SizedBox(height: 16),

              // ===== Save Button =====
              ElevatedButton(
                onPressed: () {
                  _updateClientFromFields();
                  if (_formKey.currentState!.validate()) {
                    Navigator.pop(context, editedClient);
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
