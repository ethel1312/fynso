import 'package:flutter/services.dart';

class TimezoneUtil {
  static const MethodChannel _ch = MethodChannel('com.fynso/timezone');

  /// Devuelve la TZ IANA del dispositivo (ej. "America/Lima").
  static Future<String> deviceTimeZone() async {
    try {
      final tz = await _ch.invokeMethod<String>('getTimeZoneName');
      if (tz == null || tz.trim().isEmpty) return 'UTC';
      return tz;
    } catch (_) {
      return 'UTC';
    }
  }
}
