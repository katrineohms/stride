class Client {
  final String clientId;
  final String name;
  final int age;
  final String gender;
  final int active;
  final int nextAppointment; // Unix timestamp
  final String motivation;

  Client({
    required this.clientId,
    required this.name,
    required this.age,
    required this.gender,
    required this.active,
    required this.nextAppointment,
    required this.motivation,
  });
}
