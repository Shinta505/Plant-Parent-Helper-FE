import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/cupertino.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Inisialisasi notifikasi dan timezone
  Future<void> init() async {
    tz.initializeTimeZones(); // Tanpa scheduledTime di sini

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint("Notification tapped with payload: ${response.payload}");
      },
    );
  }

  /// Menjadwalkan notifikasi
  Future<void> scheduleTaskNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String repeatInterval = 'none',
  }) async {
    if (scheduledTime.isBefore(DateTime.now()) && repeatInterval == 'none') {
      debugPrint("Waktu notifikasi sudah lewat dan tidak berulang.");
      return;
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'plant_task_channel',
      'Jadwal Perawatan Tanaman',
      channelDescription: 'Notifikasi pengingat untuk perawatan tanaman',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    RepeatInterval? repeat;
    switch (repeatInterval.toLowerCase()) {
      case 'daily':
        repeat = RepeatInterval.daily;
        break;
      case 'weekly':
        repeat = RepeatInterval.weekly;
        break;
      default:
        repeat = null;
    }

    if (repeat != null) {
      await flutterLocalNotificationsPlugin.periodicallyShow(
        id,
        title,
        body,
        repeat,
        notificationDetails,
        payload: 'task_payload_$id',
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } else {
      final location = tz.getLocation('Asia/Jakarta');
      final scheduled = tz.TZDateTime.from(scheduledTime, location);

      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduled,
        notificationDetails,
        payload: 'task_payload_$id',
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
    debugPrint("Notifikasi dengan ID $id dibatalkan.");
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
    debugPrint("Semua notifikasi dibatalkan.");
  }
}
