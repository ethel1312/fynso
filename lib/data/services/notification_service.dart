import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings();

    const settings = InitializationSettings(
      android: android,
      iOS: darwin,
      macOS: darwin,
    );

    await _notifications.initialize(settings);
  }

  /// Pide permisos y devuelve true si quedaron concedidos.
  static Future<bool> askPermissionsOnce() async {
    return _requestPermissions();
  }

  static Future<bool> _requestPermissions() async {
    bool granted = true;

    // iOS
    final iosImpl = _notifications
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (iosImpl != null) {
      final res = await iosImpl.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      if (res == false) granted = false;
    }

    // macOS
    final macImpl = _notifications
        .resolvePlatformSpecificImplementation<
        MacOSFlutterLocalNotificationsPlugin>();
    if (macImpl != null) {
      final res = await macImpl.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      if (res == false) granted = false;
    }

    // Android 13+
    final androidImpl = _notifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl != null) {
      final res = await androidImpl.requestNotificationsPermission();
      // En Android <13 res suele ser null -> lo tratamos como OK
      if (res == false) granted = false;
    }

    debugPrint('Notifications permission granted? $granted');
    return granted;
  }

  static Future<void> show({
    required String title,
    required String body,
    bool isBudgetAlert = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Defaults en false para no “simular” que están activadas
    final pushEnabled = prefs.getBool('push_notifications') ?? false;
    final budgetEnabled = prefs.getBool('budget_alerts') ?? false;

    if (!pushEnabled) return;
    if (isBudgetAlert && !budgetEnabled) return;

    const androidDetails = AndroidNotificationDetails(
      'fynso_budget_channel',
      'Alertas de presupuesto',
      channelDescription:
      'Notificaciones cuando te acercas o superas tu presupuesto mensual',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      color: Color(0xFF005EFF),
    );

    const details = NotificationDetails(android: androidDetails);

    await _notifications.show(0, title, body, details);
  }
}
