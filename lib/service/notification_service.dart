import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Service to manage persistent notifications for active sessions
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  
  factory NotificationService() => _instance;
  
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Initialize notification service
  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(initSettings);
    _initialized = true;
  }

  /// Show or update the session notification
  Future<void> showSessionNotification({
    required int? currentHr,
    required Duration duration,
  }) async {
    if (!_initialized) await initialize();

    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    final timeStr = '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';

    final hrText = currentHr != null ? '$currentHr bpm' : 'Waiting for HR...';

    const androidDetails = AndroidNotificationDetails(
      'session_channel',
      'HR Session',
      channelDescription: 'Ongoing heart rate monitoring session',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true, // Makes it persistent
      autoCancel: false,
      showWhen: false,
      icon: '@mipmap/ic_launcher',
    );

    const details = NotificationDetails(android: androidDetails);

    await _notifications.show(
      1, // Notification ID
      'HR Session Active',
      '$hrText • $timeStr',
      details,
    );
  }

  /// Cancel the session notification
  Future<void> cancelSessionNotification() async {
    await _notifications.cancel(1);
  }
}
