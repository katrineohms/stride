import '../model/clients.dart';

class CreateClientViewModel {
  String name = '';
  int? age;
  String gender = 'Male';
  int active = 0; // 0 = green, 1 = yellow, 2 = red
  DateTime? nextAppointment;
  String motivation = '';

  // Optional: validation error messages
  String? validateName() {
    if (name.isEmpty) return 'Enter a name';
    return null;
  }

  String? validateAge() {
    if (age == null || age! <= 0) return 'Enter a valid age';
    return null;
  }

  String? validateNextAppointment() {
    if (nextAppointment == null) return 'Pick a next appointment';
    return null;
  }

  bool validateAll() {
    return validateName() == null &&
        validateAge() == null &&
        validateNextAppointment() == null;
  }

  Client createClient() {
    if (!validateAll()) {
      throw Exception('Cannot create client: invalid data');
    }

    return Client(
      clientId: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      age: age!,
      gender: gender,
      active: active,
      nextAppointment: nextAppointment!.millisecondsSinceEpoch ~/ 1000,
      motivation: motivation,
    );
  }
}
