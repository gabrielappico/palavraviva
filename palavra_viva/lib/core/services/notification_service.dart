import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized || kIsWeb) return; // Not supported properly on web

    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
    _initialized = true;
  }

  Future<void> scheduleBirthdayNotification(DateTime birthDate) async {
    if (kIsWeb || !_initialized) return;

    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, birthDate.month, birthDate.day, 8, 0); // 8 AM

    if (scheduledDate.isBefore(now)) {
      scheduledDate = DateTime(now.year + 1, birthDate.month, birthDate.day, 8, 0);
    }

    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        0, 
        '🎉 Feliz Aniversário do Palavra Viva!',
        'Que a paz do Senhor seja com você e que seu novo ano de vida seja abençoado e cheio de luz. Parabéns!',
        tz.TZDateTime.from(scheduledDate, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'birthday_channel',
            'Aniversários',
            channelDescription: 'Notificações de feliz aniversário',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (_) {}
  }
}
