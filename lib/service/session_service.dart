import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../model/_models.dart';
import '../service/movesense_service.dart';
import '../service/client_data_service.dart';
import '../service/notification_service.dart';
import '../service/gps_service.dart';

/// Service to manage HR monitoring sessions
class SessionService extends ChangeNotifier {
  static final SessionService _instance = SessionService._internal();
  
  factory SessionService() => _instance;
  
  SessionService._internal();

  // Active session state
  Session? _activeSession;
  String? _activeClientId;
  StreamSubscription<int>? _hrSubscription;
  Timer? _saveTimer;
  Timer? _notificationTimer;
  final List<HrReading> _pendingReadings = [];
  final List<int> _hrWindow = [];
  static const int _medianWindowSize = 5;
  final GpsService _gpsService = GpsService();

  // Public accessors
  Session? get activeSession => _activeSession;
  String? get activeClientId => _activeClientId;
  bool get hasActiveSession => _activeSession != null;

  /// Start a new session for a client
  /// If [scheduledSession] is provided, it will be reused (for scheduled sessions)
  /// Otherwise, creates a new session immediately (for quick start)
  Future<void> startSession(String clientId, {Session? scheduledSession}) async {
    if (_activeSession != null) {
      throw Exception('A session is already active. Stop it first.');
    }

    final movesense = MovesenseService().viewModel;
    final hrStream = movesense.heartRateStream;

    if (!movesense.isConnected || hrStream == null) {
      throw Exception('No Movesense device connected.');
    }

    final startCity = await _gpsService.getLocationCityName();

    if (scheduledSession != null) {
      // Reuse the scheduled session
      _activeSession = scheduledSession.copyWith(
        hrReadings: [],
        startLocationCity: startCity,
      );
    } else {
      // Quick start - create new session immediately
      final sessionId = const Uuid().v4();
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      
      _activeSession = Session(
        sessionId: sessionId,
        startTime: now,
        hrReadings: [],
        startLocationCity: startCity,
      );
    }
    _activeClientId = clientId;
    _pendingReadings.clear();

    // Listen to heart rate stream
    _hrSubscription = hrStream.listen((hr) {
      if (hr > 0) {
        final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        _hrWindow.add(hr);
        if (_hrWindow.length > _medianWindowSize) {
          _hrWindow.removeAt(0);
        }
        final filtered = _median(_hrWindow);
        _pendingReadings.add(
          HrReading(timestamp: timestamp, heartRate: filtered),
        );
      }
    });

    // Save readings every 30 seconds
    _saveTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _flushReadings();
    });

    // Update notification every 2 seconds
    _notificationTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _updateNotification();
    });

    // Enable wakelock to prevent device from sleeping
    await WakelockPlus.enable();

    // Show initial notification
    await NotificationService().initialize();
    await _updateNotification();

    notifyListeners();
  }

  /// Stop the active session
  Future<void> stopSession() async {
    if (_activeSession == null || _activeClientId == null) return;

    // Disable wakelock
    await WakelockPlus.disable();

    // Cancel timers and subscriptions
    await _hrSubscription?.cancel();
    _saveTimer?.cancel();
    _notificationTimer?.cancel();
    await NotificationService().cancelSessionNotification();

    // Flush remaining readings
    _flushReadings();

    // Mark session as ended
    final endTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    _activeSession = _activeSession!.copyWith(
      endTime: endTime,
    );

    // Save session to client
    final client = ClientDataService().getClientById(_activeClientId!);
    if (client != null) {
      final updatedSessions = List<Session>.from(client.sessions)
        ..add(_activeSession!);
      final updatedClient = client.copyWith(sessions: updatedSessions);
      await ClientDataService().updateClient(updatedClient);
    }

    // Clear state
    _activeSession = null;
    _activeClientId = null;
    _hrSubscription = null;
    _saveTimer = null;
    _notificationTimer = null;
    _pendingReadings.clear();

    notifyListeners();
  }

  /// Flush pending readings to the active session
  void _flushReadings() {
    if (_activeSession == null || _pendingReadings.isEmpty) return;

    final allReadings = [
      ..._activeSession!.hrReadings,
      ..._pendingReadings,
    ];

    _activeSession = _activeSession!.copyWith(hrReadings: allReadings);
    _pendingReadings.clear();
    notifyListeners();
  }

  int _median(List<int> values) {
    if (values.isEmpty) return 0;
    final sorted = List<int>.from(values)..sort();
    final mid = sorted.length ~/ 2;
    if (sorted.length.isOdd) return sorted[mid];
    return ((sorted[mid - 1] + sorted[mid]) / 2).round();
  }

  /// Get current HR for display
  int? get currentHeartRate {
    if (_pendingReadings.isEmpty) return null;
    return _pendingReadings.last.heartRate;
  }

  /// Get session duration (live)
  Duration? get sessionDuration {
    if (_activeSession == null) return null;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return Duration(seconds: now - _activeSession!.startTime);
  }

  /// Update notification with current session data
  Future<void> _updateNotification() async {
    if (_activeSession == null) return;
    await NotificationService().showSessionNotification(
      currentHr: currentHeartRate,
      duration: sessionDuration ?? Duration.zero,
    );
  }

  @override
  void dispose() {
    _hrSubscription?.cancel();
    _saveTimer?.cancel();
    _notificationTimer?.cancel();
    super.dispose();
  }
}
