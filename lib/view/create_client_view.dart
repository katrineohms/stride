import 'package:flutter/material.dart';
import '../model/clients.dart'; // your Client class

class CreateClientPage extends StatefulWidget {
  final void Function(Client) onCreate; // callback to pass new client back

  const CreateClientPage({super.key, required this.onCreate});

  @override
  State<CreateClientPage> createState() => _CreateClientPageState();
}

class _CreateClientPageState extends State<CreateClientPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  String _gender = 'Male';
  int _active = 0; // 0 = green, 1 = yellow, 2 = red
  DateTime? _nextAppointment;
  final TextEditingController _motivationController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _motivationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Client'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter a name' : null,
              ),
              const SizedBox(height: 12),

              // Age
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter age';
                  final age = int.tryParse(value);
                  if (age == null || age <= 0) return 'Enter valid age';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Gender
              DropdownButtonFormField<String>(
                initialValue: _gender,
                decoration: const InputDecoration(labelText: 'Gender'),
                items: ['Male', 'Female', 'Other']
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _gender = value);
                },
              ),
              const SizedBox(height: 12),

              // Status
              DropdownButtonFormField<int>(
                initialValue: _active,
                decoration: const InputDecoration(labelText: 'Status'),
                items: const [
                  DropdownMenuItem(value: 0, child: Text('Active (Green)')),
                  DropdownMenuItem(value: 1, child: Text('Caution (Yellow)')),
                  DropdownMenuItem(value: 2, child: Text('Inactive (Red)')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _active = value);
                },
              ),
              const SizedBox(height: 12),

              // Next appointment
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(_nextAppointment == null
                    ? 'Select Next Appointment'
                    : 'Next Appointment: ${_nextAppointment!.toLocal()}'.split(' ')[0]),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _nextAppointment ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) {
                    setState(() => _nextAppointment = picked);
                  }
                },
              ),
              const SizedBox(height: 12),

              // Motivation
              TextFormField(
                controller: _motivationController,
                decoration: const InputDecoration(
                  labelText: 'Motivation',
                  hintText: 'Optional motivation notes',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Create Button
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    if (_nextAppointment == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Pick a next appointment')));
                      return;
                    }

                    final newClient = Client(
                      clientId: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: _nameController.text,
                      age: int.parse(_ageController.text),
                      gender: _gender,
                      active: _active,
                      nextAppointment:
                          _nextAppointment!.millisecondsSinceEpoch ~/ 1000,
                      motivation: _motivationController.text,
                    );

                    widget.onCreate(newClient); // pass back new client
                    Navigator.pop(context); // close form
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
