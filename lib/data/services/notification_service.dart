import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _notifications.initialize(settings);
  }

  static Future<void> show({
    required String title,
    required String body,
    bool isBudgetAlert = false, // Nueva bandera
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final pushEnabled = prefs.getBool('push_notifications') ?? true;
    final budgetEnabled = prefs.getBool('budget_alerts') ?? true;

    // Verificar preferencias
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
    await _notifications.show(
      0,
      title,
      body,
      const NotificationDetails(android: androidDetails),
    );
  }
}
