import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:io';

class NotificationService {
  // Singleton pattern untuk memastikan hanya ada satu instance service
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// ✔️ Inisialisasi service, termasuk setup timezone dan izin notifikasi
  Future<void> init() async {
    // Inisialisasi database timezone
    tz.initializeTimeZones();
    // Menentukan lokasi timezone, penting untuk penjadwalan
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    // Konfigurasi untuk Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(
            '@mipmap/launcher_icon'); // Pastikan ikon ini ada

    // Konfigurasi untuk iOS
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

    // Proses inisialisasi plugin notifikasi
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint("Notifikasi diklik dengan payload: ${response.payload}");
        // Di sini Anda bisa menambahkan navigasi ke halaman tertentu
      },
    );

    // Meminta izin notifikasi jika di platform Android
    if (Platform.isAndroid) {
      await _requestAndroidPermission();
    }
  }

  /// 🔒 Meminta izin notifikasi di Android (wajib untuk API 33+)
  Future<void> _requestAndroidPermission() async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  /// 📅 Menjadwalkan notifikasi
  Future<void> scheduleTaskNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String repeatInterval = 'none',
  }) async {
    // Memastikan waktu yang dijadwalkan tidak di masa lalu (untuk notifikasi sekali jalan)
    if (scheduledTime.isBefore(DateTime.now()) && repeatInterval == 'none') {
      debugPrint(
          "Waktu notifikasi sudah lewat dan tidak berulang, dibatalkan.");
      return;
    }

    // Detail spesifik untuk notifikasi Android
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'plant_task_channel_id', // ID unik untuk channel
      'Jadwal Perawatan Tanaman',
      channelDescription: 'Notifikasi untuk jadwal penyiraman dan pemupukan.',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
          presentAlert: true, presentBadge: true, presentSound: true),
    );

    // Mengonversi DateTime ke TZDateTime sesuai timezone lokal
    final tz.TZDateTime scheduledTZTime =
        tz.TZDateTime.from(scheduledTime, tz.local);

    debugPrint(
        "Menjadwalkan notifikasi ID: $id pada $scheduledTZTime dengan interval: $repeatInterval");

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledTZTime,
      notificationDetails,
      payload: 'task_payload_$id',
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: _getMatchDateTimeComponents(repeatInterval),
    );
  }

  /// Menentukan komponen waktu yang cocok untuk notifikasi berulang
  DateTimeComponents? _getMatchDateTimeComponents(String repeatInterval) {
    switch (repeatInterval.toLowerCase()) {
      case 'daily':
        return DateTimeComponents
            .time; // Berulang setiap hari pada jam yang sama
      case 'weekly':
        return DateTimeComponents
            .dayOfWeekAndTime; // Berulang setiap minggu pada hari dan jam yang sama
      default:
        return null; // Tidak berulang
    }
  }

  /// ❌ Membatalkan notifikasi berdasarkan ID
  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
    debugPrint("Notifikasi dengan ID $id telah dibatalkan.");
  }
}
