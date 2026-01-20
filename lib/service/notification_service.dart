import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

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

    // Request notification permission (Android 13+)
    await Permission.notification.request();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);

    // Create notification channel (Android 8+)
    const channel = AndroidNotificationChannel(
      'session_channel',
      'HR Session',
      description: 'Ongoing heart rate monitoring session',
      importance: Importance.low,
      enableVibration: false,
      playSound: false,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    _initialized = true;
    debugPrint('Notification service initialized');
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
      importance: Importance.max,
      priority: Priority.high,
      ongoing: true, // Makes it persistent
      autoCancel: false,
      showWhen: true,
    );

    const details = NotificationDetails(android: androidDetails);

    try {
      await _notifications.show(
        1, // Notification ID
        'HR Session Active',
        '$hrText • $timeStr',
        details,
      );
      debugPrint('Notification shown: $hrText • $timeStr');
    } catch (e) {
      debugPrint('Error showing notification: $e');
    }
  }

  /// Cancel the session notification
  Future<void> cancelSessionNotification() async {
    try {
      await _notifications.cancel(1);
      debugPrint('Notification cancelled');
    } catch (e) {
      debugPrint('Error cancelling notification: $e');
    }
  }
}
