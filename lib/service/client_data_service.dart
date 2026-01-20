// Plugins
import 'dart:async';
import 'dart:io';

// Packages
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';

// Files
import '../model/clients.dart';

/// ============= Client Data Service =============
/// Centralized service for managing client data persisted with Sembast.
/// All mutating operations write to disk while keeping an in-memory cache.
class ClientDataService {
  // Singleton instance
  static final ClientDataService _instance = ClientDataService._internal();

  // Local cache for fast reads
  final List<Client> _clients = [];

  // Sembast database and store references
  final StoreRef<String, Map<String, Object?>> _store =
      stringMapStoreFactory.store('clients');
  Database? _db;
  Future<void>? _initFuture;

  ClientDataService._internal();

  factory ClientDataService() => _instance;

  /// Ensure the database is opened and cache is hydrated.
  /// Optionally seed with dummy data if the store is empty.
  Future<void> init({bool seedDummyData = false}) {
    _initFuture ??= _openAndLoad(seedDummyData: seedDummyData);
    return _initFuture!;
  }

  Future<void> _openAndLoad({required bool seedDummyData}) async {
    final db = await _openDatabase();
    await _loadFromStore(db);

    if (seedDummyData && _clients.isEmpty) {
      _clients.addAll(_generateDummyClients());
      await _persistAll(db);
    }
  }

  Future<Database> _openDatabase() async {
    if (_db != null) return _db!;

    final appDir = await getApplicationDocumentsDirectory();
    final dbDir = Directory(p.join(appDir.path, 'stride_data'));
    await dbDir.create(recursive: true);
    final dbPath = p.join(dbDir.path, 'clients.db');

    _db = await databaseFactoryIo.openDatabase(dbPath);
    return _db!;
  }

  Future<void> _loadFromStore(Database db) async {
    final snapshots = await _store.find(db);
    _clients
      ..clear()
      ..addAll(
        snapshots.map((record) => _clientFromMap(record.key, record.value)),
      );
  }

  Future<void> _persistAll(Database db) async {
    await db.transaction((txn) async {
      await _store.delete(txn);
      for (final client in _clients) {
        await _store.record(client.clientId).put(txn, _clientToMap(client));
      }
    });
  }

  Future<void> _saveClient(Database db, Client client) async {
    await _store.record(client.clientId).put(db, _clientToMap(client));
  }

  // ===== Public Accessors =====
  /// Get all clients currently in memory.
  List<Client> getClients() => List.unmodifiable(_clients);

  /// Get a single client by ID.
  Client? getClientById(String clientId) {
    try {
      return _clients.firstWhere((c) => c.clientId == clientId);
    } catch (_) {
      return null;
    }
  }

  // ===== CRUD Operations =====
  /// Add a new client and persist to disk.
  Future<void> addClient(Client client) async {
    await init();
    _clients.removeWhere((c) => c.clientId == client.clientId);
    _clients.add(client);
    final db = await _openDatabase();
    await _saveClient(db, client);
  }

  /// Update an existing client and persist changes.
  Future<void> updateClient(Client updatedClient) async {
    await init();
    final index = _clients.indexWhere((c) => c.clientId == updatedClient.clientId);
    if (index != -1) {
      _clients[index] = updatedClient;
      final db = await _openDatabase();
      await _saveClient(db, updatedClient);
    }
  }

  /// Delete a client from cache and disk.
  Future<void> deleteClient(String clientId) async {
    await init();
    _clients.removeWhere((c) => c.clientId == clientId);
    final db = await _openDatabase();
    await _store.record(clientId).delete(db);
  }

  /// Replace all clients with a provided list and persist.
  Future<void> replaceAll(List<Client> clients) async {
    await init();
    _clients
      ..clear()
      ..addAll(clients);
    final db = await _openDatabase();
    await _persistAll(db);
  }

  // ===== Data Initialization =====
  /// Initialize with dummy data and persist (useful for demos/dev).
  Future<void> initializeDummyData({bool persist = true}) async {
    await init();
    _clients
      ..clear()
      ..addAll(_generateDummyClients());
    if (persist) {
      final db = await _openDatabase();
      await _persistAll(db);
    }
  }

  /// Generate dummy clients for testing.
  List<Client> _generateDummyClients() {
    final now = DateTime.now();

    return [
      Client(
        clientId: '1',
        name: 'AnnaDummy',
        age: 25,
        gender: 'Female',
        active: 0,
        motivation: 'Motivated',
        exerciseTemplates: [
          CountableExercise(
            exerciseId: '1_1',
            name: 'Push-ups',
            description: 'Standard push-ups',
            sets: 3,
            reps: 12,
          ),
          TimeableExercise(
            exerciseId: '1_2',
            name: 'Running',
            description: 'Treadmill running',
            time: 30,
          ),
        ],
        sessions: [
          // Upcoming appointment in 1 hour
          Session(
            sessionId: '1_session_1',
            appointment: Appointment(
              timestamp:
                  (now.add(const Duration(hours: 1)).millisecondsSinceEpoch ~/ 1000),
              isCompleted: false,
            ),
            startTime:
                (now.add(const Duration(hours: 1)).millisecondsSinceEpoch ~/ 1000),
            hrReadings: const [],
          ),
          // Upcoming appointment in 3 days
          Session(
            sessionId: '1_session_2',
            appointment: Appointment(
              timestamp:
                  (now.add(const Duration(days: 3)).millisecondsSinceEpoch ~/ 1000),
              isCompleted: false,
            ),
            startTime:
                (now.add(const Duration(days: 3)).millisecondsSinceEpoch ~/ 1000),
            hrReadings: const [],
          ),
        ],
      ),
      Client(
        clientId: '2',
        name: 'MarkDummy',
        age: 30,
        gender: 'Male',
        active: 1,
        motivation: 'Needs support',
        exerciseTemplates: const [],
        sessions: [
          // Upcoming appointment in 2 days
          Session(
            sessionId: '2_session_1',
            appointment: Appointment(
              timestamp:
                  (now.add(const Duration(days: 2)).millisecondsSinceEpoch ~/ 1000),
              isCompleted: false,
            ),
            startTime:
                (now.add(const Duration(days: 2)).millisecondsSinceEpoch ~/ 1000),
            hrReadings: const [],
          ),
        ],
      ),
      Client(
        clientId: '3',
        name: 'SophiaDummy',
        age: 28,
        gender: 'Female',
        active: 2,
        motivation: 'Struggling',
        exerciseTemplates: const [],
        sessions: [
          // Upcoming appointment in 5 days
          Session(
            sessionId: '3_session_1',
            appointment: Appointment(
              timestamp:
                  (now.add(const Duration(days: 5)).millisecondsSinceEpoch ~/ 1000),
              isCompleted: false,
            ),
            startTime:
                (now.add(const Duration(days: 5)).millisecondsSinceEpoch ~/ 1000),
            hrReadings: const [],
          ),
          // Upcoming appointment in 7 days
          Session(
            sessionId: '3_session_2',
            appointment: Appointment(
              timestamp:
                  (now.add(const Duration(days: 7)).millisecondsSinceEpoch ~/ 1000),
              isCompleted: false,
            ),
            startTime:
                (now.add(const Duration(days: 7)).millisecondsSinceEpoch ~/ 1000),
            hrReadings: const [],
          ),
        ],
      ),
    ];
  }

  // ===== Search & Filter =====
  /// Search clients by name.
  List<Client> searchClients(String query) {
    if (query.isEmpty) return getClients();
    return _clients
        .where((c) => c.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  /// Get clients with appointments on a given day.
  List<Client> getClientsForDay(DateTime day) {
    return _clients.where((client) {
      return client.sessions.any((session) {
        final appointmentDate = DateTime.fromMillisecondsSinceEpoch(
          session.appointment.timestamp * 1000,
        );
        return appointmentDate.year == day.year &&
            appointmentDate.month == day.month &&
            appointmentDate.day == day.day;
      });
    }).toList();
  }

  // ===== Utility =====
  /// Clear all data from cache and storage.
  Future<void> clear() async {
    await init();
    _clients.clear();
    final db = await _openDatabase();
    await _store.delete(db);
  }

  /// Get client count from the in-memory cache.
  int getClientCount() => _clients.length;

  // ===== Serialization Helpers =====
  Map<String, Object?> _clientToMap(Client client) {
    return {
      'clientId': client.clientId,
      'name': client.name,
      'age': client.age,
      'gender': client.gender,
      'active': client.active,
      'motivation': client.motivation,
      'exerciseTemplates': client.exerciseTemplates.map(_exerciseToMap).toList(),
      'sessions': client.sessions.map(_sessionToMap).toList(),
    };
  }

  Client _clientFromMap(String key, Map<String, Object?> map) {
    final exerciseTemplates = (map['exerciseTemplates'] as List?)
            ?.map((raw) => _exerciseFromMap(raw as Map<String, Object?>))
            .toList() ??
        const <Exercise>[];

    final sessions = (map['sessions'] as List?)
            ?.map((raw) => _sessionFromMap(raw as Map<String, Object?>))
            .toList() ??
        const <Session>[];

    return Client(
      clientId: map['clientId']?.toString() ?? key,
      name: map['name']?.toString() ?? 'Unknown',
      age: (map['age'] as num?)?.toInt() ?? 0,
      gender: map['gender']?.toString() ?? 'Unspecified',
      active: (map['active'] as num?)?.toInt() ?? 0,
      motivation: map['motivation']?.toString() ?? '',
      exerciseTemplates: exerciseTemplates,
      sessions: sessions,
    );
  }

  Map<String, Object?> _exerciseToMap(Exercise exercise) {
    if (exercise is CountableExercise) {
      return {
        'type': 'countable',
        'exerciseId': exercise.exerciseId,
        'name': exercise.name,
        'description': exercise.description,
        'reps': exercise.reps,
        'sets': exercise.sets,
        'isCompleted': exercise.isCompleted,
      };
    }

    if (exercise is TimeableExercise) {
      return {
        'type': 'timeable',
        'exerciseId': exercise.exerciseId,
        'name': exercise.name,
        'description': exercise.description,
        'time': exercise.time,
        'isCompleted': exercise.isCompleted,
      };
    }

    return {
      'type': 'base',
      'exerciseId': exercise.exerciseId,
      'name': exercise.name,
      'description': exercise.description,
      'isCompleted': exercise.isCompleted,
    };
  }

  Exercise _exerciseFromMap(Map<String, Object?> map) {
    final type = map['type']?.toString();
    final exerciseId = map['exerciseId']?.toString() ?? 'unknown';
    final name = map['name']?.toString() ?? 'Unknown';
    final description = map['description']?.toString() ?? '';
    final isCompleted = (map['isCompleted'] as bool?) ?? false;

    switch (type) {
      case 'countable':
        return CountableExercise(
          exerciseId: exerciseId,
          name: name,
          description: description,
          reps: (map['reps'] as num?)?.toInt() ?? 0,
          sets: (map['sets'] as num?)?.toInt() ?? 0,
          isCompleted: isCompleted,
        );
      case 'timeable':
        return TimeableExercise(
          exerciseId: exerciseId,
          name: name,
          description: description,
          time: (map['time'] as num?)?.toInt() ?? 0,
          isCompleted: isCompleted,
        );
      default:
        return Exercise(
          exerciseId: exerciseId,
          name: name,
          description: description,
          isCompleted: isCompleted,
        );
    }
  }

  Map<String, Object?> _appointmentToMap(Appointment appointment) {
    return {
      'timestamp': appointment.timestamp,
      'notes': appointment.notes,
      'isCompleted': appointment.isCompleted,
    };
  }

  Appointment _appointmentFromMap(Map<String, Object?> map) {
    return Appointment(
      timestamp: (map['timestamp'] as num?)?.toInt() ?? 0,
      notes: map['notes']?.toString(),
      isCompleted: (map['isCompleted'] as bool?) ?? false,
    );
  }

  Map<String, Object?> _sessionToMap(Session session) {
    return {
      'sessionId': session.sessionId,
      'appointment': _appointmentToMap(session.appointment),
      'startTime': session.startTime,
      'endTime': session.endTime,
      'startLocationCity': session.startLocationCity,
      'hrReadings': session.hrReadings
          .map((r) => {'timestamp': r.timestamp, 'heartRate': r.heartRate})
          .toList(),
      'exercises': session.exercises.map(_exerciseToMap).toList(),
      'hrrResults': session.hrrResults.map(
        (key, value) => MapEntry(key, {'high': value.high, 'low': value.low}),
      ),
    };
  }

  Session _sessionFromMap(Map<String, Object?> map) {
    final hrReadings = (map['hrReadings'] as List?)
            ?.map(
              (raw) {
                final reading = (raw as Map).cast<String, Object?>();
                return HrReading(
                  timestamp: (reading['timestamp'] as num?)?.toInt() ?? 0,
                  heartRate: (reading['heartRate'] as num?)?.toInt() ?? 0,
                );
              },
            )
            .toList() ??
        const <HrReading>[];

    final exercises = (map['exercises'] as List?)
            ?.map((raw) => _exerciseFromMap(raw as Map<String, Object?>))
            .toList() ??
        const <Exercise>[];

    final hrrResults = (map['hrrResults'] as Map?)?.map(
          (k, v) => MapEntry(
            k.toString(),
            _hrrFromMap((v as Map).cast<String, Object?>()),
          ),
        ) ??
        const <String, HeartRateRecovery>{};

    // Default appointment if missing (for backward compatibility)
    final appointmentMap = map['appointment'] as Map<String, Object?>?;
    final appointment = appointmentMap != null
        ? _appointmentFromMap(appointmentMap)
        : Appointment(
            timestamp: (map['startTime'] as num?)?.toInt() ?? 0,
            isCompleted: true,
          );

    return Session(
      sessionId: map['sessionId']?.toString() ?? 'unknown',
      appointment: appointment,
      startTime: (map['startTime'] as num?)?.toInt() ?? 0,
      endTime: (map['endTime'] as num?)?.toInt(),
      hrReadings: hrReadings,
      startLocationCity: map['startLocationCity']?.toString(),
      exercises: exercises,
      hrrResults: hrrResults,
    );
  }

  HeartRateRecovery _hrrFromMap(Map<String, Object?> map) {
    return HeartRateRecovery(
      high: (map['high'] as num?)?.toInt() ?? 0,
      low: (map['low'] as num?)?.toInt() ?? 0,
    );
  }
}
