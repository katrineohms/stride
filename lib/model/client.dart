import 'exercise.dart';
import 'session.dart';

class Client {
  final String clientId;
  final String name;
  final int age;
  final String gender;
  final int active;
  final String motivation;
  /// Exercise templates owned by the client (copied into sessions when used)
  final List<Exercise> exerciseTemplates;
  final List<Session> sessions;

  Client({
    required this.clientId,
    required this.name,
    required this.age,
    required this.gender,
    required this.active,
    required this.motivation,
    List<Exercise>? exerciseTemplates,
    List<Session>? sessions,
  })  : exerciseTemplates = List.unmodifiable(exerciseTemplates ?? []),
        sessions = List.unmodifiable(sessions ?? []);

  Client copyWith({
    String? clientId,
    String? name,
    int? age,
    String? gender,
    int? active,
    String? motivation,
    List<Exercise>? exerciseTemplates,

    List<Session>? sessions,
  }) {
    return Client(
      clientId: clientId ?? this.clientId,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      active: active ?? this.active,
      motivation: motivation ?? this.motivation,
      exerciseTemplates: exerciseTemplates ?? this.exerciseTemplates,
      sessions: sessions ?? this.sessions,
    );
  }
}
