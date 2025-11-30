import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  static bool _tzInitDone = false;

  // IDs fijos de las notificaciones de recordatorio
  static const int _reminderId1 = 1001;
  static const int _reminderId2 = 1002;

  // ================== INIT ==================

  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings();

    const settings = InitializationSettings(
      android: android,
      iOS: darwin,
      macOS: darwin,
    );

    await _notifications.initialize(settings);
    await _ensureTimezoneInit();
  }

  static Future<void> _ensureTimezoneInit() async {
    if (_tzInitDone) return;

    tz.initializeTimeZones();
    try {
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      debugPrint('🔔 Timezone inicializada: $timeZoneName');
    } catch (e) {
      debugPrint(
        '⚠️ No se pudo obtener timezone del dispositivo, uso por defecto: $e',
      );
      // tz.local se quedará con el valor por defecto (probablemente UTC)
    }

    _tzInitDone = true;
  }

  // ================== PERMISOS ==================

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

  // ================== NOTIF INMEDIATAS (ya tenías) ==================

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

  // ================== RECORDATORIOS DIARIOS ==================
  //
  // Idea:
  // - Se recalculan NUEVAS horas aleatorias CADA DÍA
  //   cuando la app llama a refreshDailyRemindersFromPrefs (p.ej. al abrir Home).
  // - Rangos (hora local del dispositivo):
  //     * Primer recordatorio: 09:00–12:59
  //     * Segundo recordatorio: 18:00–21:59
  // - Mínimo ~3h de diferencia (en la práctica hay mucho más por las ventanas)
  // - Si el usuario no abre la app, no se reprograman para ese día.

  /// Llama esto cuando:
  /// - Inicia la app (por ejemplo, en HomeScreen.initState)
  /// - El usuario activa o desactiva `push_notifications` en tus preferencias
  ///
  /// Comportamiento:
  /// - Si `push_notifications = false` → cancela recordatorios.
  /// - Si `push_notifications = true`  → si aún no se ha programado para HOY
  ///   se cancelan los anteriores y se generan 2 nuevas horas random.
  static Future<void> refreshDailyRemindersFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final pushEnabled = prefs.getBool('push_notifications') ?? false;

    if (!pushEnabled) {
      await _cancelDailyReminders();
      await prefs.remove('last_reminders_scheduled_day');
      return;
    }

    await _ensureTimezoneInit();

    final now = tz.TZDateTime.now(tz.local);
    final todayStr =
        '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final lastDay = prefs.getString('last_reminders_scheduled_day');

    // Ya tiene recordatorios programados para este día
    if (lastDay == todayStr) {
      return;
    }

    // Nuevo día → cancelar anteriores y reprogramar con nuevas horas
    await _cancelDailyReminders();
    await _scheduleRemindersFromNow(now);
    await prefs.setString('last_reminders_scheduled_day', todayStr);
  }

  static Future<void> _cancelDailyReminders() async {
    await _notifications.cancel(_reminderId1);
    await _notifications.cancel(_reminderId2);
  }

  static Future<void> _scheduleRemindersFromNow(tz.TZDateTime now) async {
    await _ensureTimezoneInit();
    final rnd = Random();

    tz.TZDateTime _randomTimeInWindow({
      required int startHour,
      required int endHour,
    }) {
      final baseDay = tz.TZDateTime(tz.local, now.year, now.month, now.day);
      final hour = startHour + rnd.nextInt(endHour - startHour + 1);
      final minute = rnd.nextInt(60);

      var t = tz.TZDateTime(
        tz.local,
        baseDay.year,
        baseDay.month,
        baseDay.day,
        hour,
        minute,
      );

      if (t.isBefore(now.add(const Duration(minutes: 5)))) {
        t = t.add(const Duration(days: 1));
      }
      return t;
    }

    final t1 = _randomTimeInWindow(startHour: 9, endHour: 12);
    tz.TZDateTime t2;
    do {
      t2 = _randomTimeInWindow(startHour: 18, endHour: 21);
    } while ((t2.difference(t1).inHours).abs() < 3);

    const androidDetails = AndroidNotificationDetails(
      'fynso_reminder_channel',
      'Recordatorios diarios',
      channelDescription: 'Recordatorios para registrar tus gastos diarios',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      color: Color(0xFF005EFF),
    );

    const details = NotificationDetails(android: androidDetails);

    await _notifications.zonedSchedule(
      _reminderId1,
      'No olvides tus gastos de hoy',
      'Tómate 1 minuto para registrar tus últimos gastos en Fynso 💙',
      t1,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: 'daily_reminder_1',
    );

    await _notifications.zonedSchedule(
      _reminderId2,
      'Repasa tus gastos del día',
      'Un pequeño repaso en Fynso puede ahorrarte sorpresas a fin de mes ✨',
      t2,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: 'daily_reminder_2',
    );

    debugPrint('✅ Recordatorios programados: t1=$t1, t2=$t2 (zona: ${tz.local.name})');
  }
}
