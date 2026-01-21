// Plugins
import 'dart:async';
import 'dart:convert';
import 'dart:io';

// Packages
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';

// Files
import '../model/_models.dart';

/// ============= Client Data Service =============
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

  Future<void> init() {
    _initFuture ??= _openAndLoad();
    return _initFuture!;
  }

  Future<void> _openAndLoad() async {
    final db = await _openDatabase();
    await _loadFromStore(db);
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

  // ===== Data Modification =====
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

  // ===== Search & Filter =====
  /// Get clients with sessions on a given day.
  List<Client> getClientsForDay(DateTime day) {
    return _clients.where((client) {
      return client.sessions.any((session) {
        final date = DateTime.fromMillisecondsSinceEpoch(
          session.startTime * 1000,
        );
        return date.year == day.year &&
            date.month == day.month &&
            date.day == day.day;
      });
    }).toList();
  }

  /// Get client count from the in-memory cache.
  int getClientCount() => _clients.length;

  // ===== Data Export =====
  /// Export all client data to a JSON file for analysis.
  /// Returns the File object for sharing.
  Future<File> dumpToJson() async {
    await init();
    
    // Get the documents directory
    final appDir = await getApplicationDocumentsDirectory();
    final exportDir = Directory(p.join(appDir.path, 'stride_data', 'exports'));
    await exportDir.create(recursive: true);
    
    // Create filename with timestamp
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final filePath = p.join(exportDir.path, 'stride_export_$timestamp.json');
    
    // Create export data structure
    final exportData = await exportAsMap();
    
    // Write to file
    final file = File(filePath);
    final jsonString = JsonEncoder.withIndent('  ').convert(exportData);
    await file.writeAsString(jsonString);
    
    return file;
  }

  /// Export all client data as a formatted JSON Map (for debugging or custom export).
  Future<Map<String, dynamic>> exportAsMap() async {
    await init();
    
    return {
      'exportTimestamp': DateTime.now().toIso8601String(),
      'clientCount': _clients.length,
      'clients': _clients.map((client) => _clientToMap(client)).toList(),
    };
  }

  // ===== Serialization Helpers: Client =====
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

  // ===== Serialization Helpers: Exercise =====
  Map<String, Object?> _exerciseToMap(Exercise exercise) {
    if (exercise is CountableExercise) {
      return {
        'type': 'countable',
        'exerciseId': exercise.exerciseId,
        'name': exercise.name,
        'description': exercise.description,
        'reps': exercise.reps,
        'sets': exercise.sets,
      };
    }

    if (exercise is TimeableExercise) {
      return {
        'type': 'timeable',
        'exerciseId': exercise.exerciseId,
        'name': exercise.name,
        'description': exercise.description,
        'time': exercise.time,
      };
    }

    return {
      'type': 'base',
      'exerciseId': exercise.exerciseId,
      'name': exercise.name,
      'description': exercise.description,
    };
  }

  Exercise _exerciseFromMap(Map<String, Object?> map) {
    final type = map['type']?.toString();
    final exerciseId = map['exerciseId']?.toString() ?? 'unknown';
    final name = map['name']?.toString() ?? 'Unknown';
    final description = map['description']?.toString() ?? '';

    switch (type) {
      case 'countable':
        return CountableExercise(
          exerciseId: exerciseId,
          name: name,
          description: description,
          reps: (map['reps'] as num?)?.toInt() ?? 0,
          sets: (map['sets'] as num?)?.toInt() ?? 0,
        );
      case 'timeable':
        return TimeableExercise(
          exerciseId: exerciseId,
          name: name,
          description: description,
          time: (map['time'] as num?)?.toInt() ?? 0,
        );
      default:
        return Exercise(
          exerciseId: exerciseId,
          name: name,
          description: description,
        );
    }
  }

  // ===== Serialization Helpers: Session =====
  Map<String, Object?> _sessionToMap(Session session) {
    return {
      'sessionId': session.sessionId,
      'startTime': session.startTime,
      'endTime': session.endTime,
      'startLocationCity': session.startLocationCity,
      'exercisesPerformed':
        session.exercisesPerformed.map(_exerciseToMap).toList(),
      'hrReadings': session.hrReadings
        .map((r) => {'timestamp': r.timestamp, 'heartRate': r.heartRate})
        .toList(),
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

    final exercisesPerformed = (map['exercisesPerformed'] as List?)
            ?.map((raw) => _exerciseFromMap(raw as Map<String, Object?>))
            .toList() ??
        const <Exercise>[];

    return Session(
      sessionId: map['sessionId']?.toString() ?? 'unknown',
      startTime: (map['startTime'] as num?)?.toInt() ?? 0,
      endTime: (map['endTime'] as num?)?.toInt(),
      hrReadings: hrReadings,
      startLocationCity: map['startLocationCity']?.toString(),
      exercisesPerformed: exercisesPerformed,
    );
  }
}

